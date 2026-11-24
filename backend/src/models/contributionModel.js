import { pool } from '../config/db.js'
import { findOrCreateCategory } from './categoryModel.js'
import { getOrCreateSystemUserId } from './userModel.js'

const columns = `
  co.id_contribution AS id, c.titre AS title,
  CONCAT_WS(' ', u.prenom, u.nom) AS author,
  COALESCE(p.titre, '') AS type, COALESCE(c.village, '') AS village,
  COALESCE(c.texte, '') AS content,
  COALESCE(p.image, '') AS \`imageUrl\`, '' AS \`imageName\`,
  COALESCE(p.video, '') AS \`mediaUrl\`, '' AS \`mediaName\`,
  CASE WHEN p.video IS NULL OR p.video = '' THEN '' ELSE 'video' END AS \`mediaType\`,
  CASE WHEN p.video LIKE '%youtube.com%' OR p.video LIKE '%youtu.be%' THEN p.video ELSE '' END AS \`youtubeUrl\`,
  co.statut AS status, co.date_soumission AS \`createdAt\`,
  co.date_moderation AS \`updatedAt\`
`
const joins = `
  FROM contribution co
  JOIN contenu c ON c.id_contribution = co.id_contribution
  JOIN categorie cat ON cat.id_categorie = c.id_categorie
  JOIN utilisateur u ON u.id_utilisateur = co.id_utilisateur
  LEFT JOIN paragraphe p ON p.id_contenu = c.id_contenu
`

export async function createContribution(item, userId) {
  const categoryId = await findOrCreateCategory('Contributions', item.type)
  const client = await pool.connect()
  try {
    await client.query('START TRANSACTION')
    const contributionResult = await client.query(
      `INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
       VALUES (?, ?, ?)`,
      [item.status, item.charterAccepted, userId],
    )
    const contentResult = await client.query(
      `INSERT INTO contenu (titre, village, texte, id_categorie, id_contribution)
       VALUES (?, ?, ?, ?, ?)`,
      [item.title, item.village || null, item.content, categoryId, contributionResult.insertId],
    )
    await client.query(
      `INSERT INTO paragraphe (titre, description, image, video, id_contenu)
       VALUES (?, ?, ?, ?, ?)`,
      [item.type, item.content, item.imageUrl || null, item.mediaUrl || item.youtubeUrl || null, contentResult.insertId],
    )
    await client.query('COMMIT')
    return findContribution(contributionResult.insertId)
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
}

export async function listContributions() {
  const { rows } = await pool.query(
    `SELECT ${columns} ${joins}
     WHERE cat.nom = 'Contributions'
     ORDER BY co.date_soumission DESC`,
  )
  return rows
}

export async function listPublishedContributions() {
  const { rows } = await pool.query(
    `SELECT ${columns} ${joins}
     WHERE cat.nom = 'Contributions' AND co.statut = 'Validé'
     ORDER BY co.date_soumission DESC`,
  )
  return rows
}

export async function findContribution(id) {
  const { rows } = await pool.query(
    `SELECT ${columns} ${joins}
     WHERE co.id_contribution = ? AND cat.nom = 'Contributions'`,
    [id],
  )
  return rows[0] || null
}

export async function updateContribution(id, item) {
  const current = await findContribution(id)
  if (!current) return null
  const { rows } = await pool.query('SELECT id_contenu AS id FROM contenu WHERE id_contribution = ?', [id])
  const contentId = rows[0]?.id
  if (!contentId) return null

  const client = await pool.connect()
  try {
    await client.query('START TRANSACTION')
    const contentFields = []
    const contentValues = []
    if (Object.hasOwn(item, 'title')) {
      contentFields.push('titre = ?')
      contentValues.push(item.title)
    }
    if (Object.hasOwn(item, 'village')) {
      contentFields.push('village = ?')
      contentValues.push(item.village || null)
    }
    if (Object.hasOwn(item, 'content')) {
      contentFields.push('texte = ?')
      contentValues.push(item.content)
    }
    if (contentFields.length) {
      await client.query(`UPDATE contenu SET ${contentFields.join(', ')} WHERE id_contenu = ?`, [...contentValues, contentId])
    }

    const paragraphFields = []
    const paragraphValues = []
    const paragraphMappings = {
      type: 'titre',
      content: 'description',
      imageUrl: 'image',
      mediaUrl: 'video',
      youtubeUrl: 'video',
    }
    for (const [key, column] of Object.entries(paragraphMappings)) {
      if (!Object.hasOwn(item, key)) continue
      paragraphFields.push(`${column} = ?`)
      paragraphValues.push(item[key] || null)
    }
    if (paragraphFields.length) {
      const { rows: paragraphs } = await client.query(
        'SELECT id_paragraphe AS id FROM paragraphe WHERE id_contenu = ? LIMIT 1',
        [contentId],
      )
      if (paragraphs[0]) {
        await client.query(
          `UPDATE paragraphe SET ${paragraphFields.join(', ')} WHERE id_paragraphe = ?`,
          [...paragraphValues, paragraphs[0].id],
        )
      }
    }
    await client.query('COMMIT')
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
  return findContribution(id)
}

export async function setContributionStatus(id, status) {
  const current = await findContribution(id)
  if (!current) return null
  const moderatorId = await getOrCreateSystemUserId()
  const client = await pool.connect()
  try {
    await client.query('START TRANSACTION')
    await client.query(
      `UPDATE contribution SET statut = ?, date_moderation = CURRENT_TIMESTAMP, id_moderateur = ?
       WHERE id_contribution = ?`,
      [status, moderatorId, id],
    )
    await client.query(
      `UPDATE contenu c JOIN contribution co ON co.id_contribution = c.id_contribution
       SET c.date_publication = CASE WHEN co.statut = 'Validé' THEN CURRENT_TIMESTAMP ELSE NULL END
       WHERE co.id_contribution = ?`,
      [id],
    )
    await client.query('COMMIT')
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
  return findContribution(id)
}

export async function deleteContribution(id) {
  const contribution = await findContribution(id)
  if (!contribution) return null
  const client = await pool.connect()
  try {
    await client.query('START TRANSACTION')
    const { rows } = await client.query('SELECT id_contenu FROM contenu WHERE id_contribution = ?', [id])
    if (rows[0]) {
      await client.query('DELETE FROM question_quiz WHERE id_contenu = ?', [rows[0].id_contenu])
      await client.query('DELETE FROM paragraphe WHERE id_contenu = ?', [rows[0].id_contenu])
      await client.query('DELETE FROM contenu WHERE id_contenu = ?', [rows[0].id_contenu])
    }
    await client.query('DELETE FROM contribution WHERE id_contribution = ?', [id])
    await client.query('COMMIT')
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
  return contribution
}

export async function listContributors() {
  const { rows } = await pool.query(`
    SELECT CONCAT_WS(' ', u.prenom, u.nom) AS name, MAX(c.village) AS village
    FROM contribution co
    JOIN contenu c ON c.id_contribution = co.id_contribution
    JOIN categorie cat ON cat.id_categorie = c.id_categorie
    JOIN utilisateur u ON u.id_utilisateur = co.id_utilisateur
    WHERE co.statut = 'Validé' AND cat.nom = 'Contributions'
    GROUP BY u.id_utilisateur, u.nom, u.prenom
    ORDER BY MAX(co.date_soumission) DESC
  `)
  return rows.map((item) => ({
    ...item,
    role: item.village ? `Contributeur, ${item.village}` : 'Contributeur culturel',
    initials: item.name.slice(0, 2).toUpperCase(),
  }))
}
