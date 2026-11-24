import { pool } from '../config/db.js'
import { findOrCreateCategory } from './categoryModel.js'
import { getOrCreateSystemUserId } from './userModel.js'

const articleColumns = `
  c.id_contenu AS id, c.titre AS title, cat.domaine AS category, cat.domaine AS theme,
  COALESCE(c.village, '') AS village, '' AS generation,
  COALESCE(p.titre, '') AS type, COALESCE(p.image, '') AS \`imageUrl\`,
  COALESCE(p.video, '') AS \`videoUrl\`,
  COALESCE(p.media_type, 'video/mp4') AS \`mediaType\`,
  COALESCE(p.contenu, '') AS description, COALESCE(p.description, '') AS excerpt,
  COALESCE(p.origines, '') AS origins,
  COALESCE(p.signification_culturelle, '') AS \`culturalMeaning\`,
  COALESCE(p.lieu_decouverte, '') AS \`discoveryPlace\`,
  COALESCE(c.texte, '') AS content, c.date_creation AS \`createdAt\`
`
const articleJoins = `
  FROM contenu c
  JOIN categorie cat ON cat.id_categorie = c.id_categorie
  JOIN contribution co ON co.id_contribution = c.id_contribution
  LEFT JOIN paragraphe p ON p.id_contenu = c.id_contenu
`

async function findArticle(id) {
  const { rows } = await pool.query(`SELECT ${articleColumns} ${articleJoins} WHERE c.id_contenu = ?`, [id])
  return rows[0] || null
}

async function createArticle(item) {
  const categoryId = await findOrCreateCategory(item.category, item.theme, item.type)
  const userId = await getOrCreateSystemUserId()
  const client = await pool.connect()
  let contentId
  let contributionId
  try {
    await client.query('START TRANSACTION')
    const contribution = await client.query(
      `INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
       VALUES ('Validé', TRUE, ?)`,
      [userId],
    )
    contributionId = contribution.insertId
    const content = await client.query(
      `INSERT INTO contenu (titre, village, texte, date_publication, id_categorie, id_contribution)
       VALUES (?, ?, ?, CURRENT_TIMESTAMP, ?, ?)`,
      [item.title, item.village || null, item.content, categoryId, contributionId],
    )
    contentId = content.insertId
    await client.query(
      `INSERT INTO paragraphe
         (titre, contenu, description, image, video, media_type, origines, signification_culturelle, lieu_decouverte, id_contenu)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        item.type || null, item.description || null, item.excerpt || null, item.imageUrl || null,
        item.videoUrl || null, item.mediaType, item.origins || null, item.culturalMeaning || null,
        item.discoveryPlace || null, contentId,
      ],
    )
    await client.query('COMMIT')
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
  return findArticle(contentId)
}

async function updateArticle(id, item) {
  const current = await findArticle(id)
  if (!current) return null
  const categoryId = await findOrCreateCategory(item.category, item.theme, item.type)
  const client = await pool.connect()
  try {
    await client.query('START TRANSACTION')
    await client.query(
      `UPDATE contenu SET titre = ?, village = ?, texte = ?, id_categorie = ? WHERE id_contenu = ?`,
      [item.title, item.village || null, item.content, categoryId, id],
    )
    const { rows } = await client.query(
      'SELECT id_paragraphe AS id FROM paragraphe WHERE id_contenu = ? LIMIT 1',
      [id],
    )
    if (rows[0]) {
      await client.query(
        `UPDATE paragraphe
         SET titre = ?, contenu = ?, description = ?, image = ?, video = ?, media_type = ?, origines = ?,
             signification_culturelle = ?, lieu_decouverte = ?
         WHERE id_paragraphe = ?`,
        [
          item.type || null, item.description || null, item.excerpt || null, item.imageUrl || null,
          item.videoUrl || null, item.mediaType, item.origins || null, item.culturalMeaning || null,
          item.discoveryPlace || null, rows[0].id,
        ],
      )
    } else {
      await client.query(
        `INSERT INTO paragraphe
           (titre, contenu, description, image, video, media_type, origines, signification_culturelle, lieu_decouverte, id_contenu)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          item.type || null, item.description || null, item.excerpt || null, item.imageUrl || null,
          item.videoUrl || null, item.mediaType, item.origins || null, item.culturalMeaning || null,
          item.discoveryPlace || null, id,
        ],
      )
    }
    await client.query('COMMIT')
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
  return findArticle(id)
}

async function removeContentAndContribution(contentId) {
  const { rows } = await pool.query(
    'SELECT id_contribution AS id FROM contenu WHERE id_contenu = ?',
    [contentId],
  )
  if (!rows[0]) return false
  const client = await pool.connect()
  try {
    await client.query('START TRANSACTION')
    await client.query('DELETE FROM question_quiz WHERE id_contenu = ?', [contentId])
    await client.query('DELETE FROM paragraphe WHERE id_contenu = ?', [contentId])
    await client.query('DELETE FROM contenu WHERE id_contenu = ?', [contentId])
    await client.query('DELETE FROM contribution WHERE id_contribution = ?', [rows[0].id])
    await client.query('COMMIT')
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
  return true
}

async function listPlaces() {
  const { rows } = await pool.query(`
    SELECT id_lieu AS id, nom AS name, COALESCE(village, '') AS village,
      COALESCE(adresse, '') AS address, COALESCE(conditions_acces, '') AS access,
      COALESCE(description, '') AS description,
      COALESCE(google_maps_url, '') AS \`googleMapsUrl\`,
      latitude, longitude, '' AS \`imageUrl\`
    FROM lieu ORDER BY nom ASC
  `)
  return rows
}

async function findPlace(id) {
  const { rows } = await pool.query(`
    SELECT id_lieu AS id, nom AS name, COALESCE(village, '') AS village,
      COALESCE(adresse, '') AS address, COALESCE(conditions_acces, '') AS access,
      COALESCE(description, '') AS description,
      COALESCE(google_maps_url, '') AS \`googleMapsUrl\`,
      latitude, longitude, '' AS \`imageUrl\`
    FROM lieu WHERE id_lieu = ?
  `, [id])
  return rows[0] || null
}

async function createPlace(item) {
  const { insertId } = await pool.query(
    `INSERT INTO lieu
       (nom, village, adresse, conditions_acces, description, latitude, longitude, google_maps_url)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      item.name, item.village || null, item.address || null, item.access || null,
      item.description || null, item.latitude ?? null, item.longitude ?? null, item.googleMapsUrl || null,
    ],
  )
  return findPlace(insertId)
}

async function updatePlace(id, item) {
  await pool.query(
    `UPDATE lieu SET nom = ?, village = ?, adresse = ?, conditions_acces = ?,
      description = ?, latitude = ?, longitude = ?, google_maps_url = ? WHERE id_lieu = ?`,
    [
      item.name, item.village || null, item.address || null, item.access || null,
      item.description || null, item.latitude ?? null, item.longitude ?? null,
      item.googleMapsUrl || null, id,
    ],
  )
  return findPlace(id)
}

async function listQuiz() {
  const { rows } = await pool.query(`
    SELECT q.id_quiz AS id, q.titre AS question, r.texte AS optionText,
      r.est_correcte AS isCorrect
    FROM question_quiz q
    LEFT JOIN reponse r ON r.id_quiz = q.id_quiz
    ORDER BY q.id_quiz ASC, r.id_reponse ASC
  `)
  const questions = new Map()
  for (const row of rows) {
    if (!questions.has(row.id)) questions.set(row.id, { id: row.id, question: row.question, options: [], answer: -1 })
    if (row.optionText !== null) {
      const question = questions.get(row.id)
      if (Number(row.isCorrect)) question.answer = question.options.length
      question.options.push(row.optionText)
    }
  }
  return [...questions.values()]
}

async function findQuiz(id) {
  const questions = await listQuiz()
  return questions.find((item) => String(item.id) === String(id)) || null
}

async function createQuiz(item) {
  const userId = await getOrCreateSystemUserId()
  const categoryId = await findOrCreateCategory('Quiz', 'Question')
  const client = await pool.connect()
  let quizId
  try {
    await client.query('START TRANSACTION')
    const contribution = await client.query(
      `INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
       VALUES ('Validé', TRUE, ?)`,
      [userId],
    )
    const content = await client.query(
      `INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
       VALUES (?, ?, CURRENT_TIMESTAMP, ?, ?)`,
      [item.question, item.question, categoryId, contribution.insertId],
    )
    const quiz = await client.query(
      'INSERT INTO question_quiz (titre, id_contenu) VALUES (?, ?)',
      [item.question, content.insertId],
    )
    quizId = quiz.insertId
    for (let index = 0; index < item.options.length; index += 1) {
      await client.query(
        'INSERT INTO reponse (texte, est_correcte, id_quiz) VALUES (?, ?, ?)',
        [item.options[index], index === item.answer, quizId],
      )
    }
    await client.query('COMMIT')
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
  return findQuiz(quizId)
}

async function updateQuiz(id, item) {
  const { rows } = await pool.query(
    `SELECT q.id_contenu AS contentId FROM question_quiz q WHERE q.id_quiz = ?`,
    [id],
  )
  if (!rows[0]) return null
  const client = await pool.connect()
  try {
    await client.query('START TRANSACTION')
    await client.query('UPDATE question_quiz SET titre = ? WHERE id_quiz = ?', [item.question, id])
    await client.query('UPDATE contenu SET titre = ?, texte = ? WHERE id_contenu = ?', [item.question, item.question, rows[0].contentId])
    await client.query('DELETE FROM reponse WHERE id_quiz = ?', [id])
    for (let index = 0; index < item.options.length; index += 1) {
      await client.query(
        'INSERT INTO reponse (texte, est_correcte, id_quiz) VALUES (?, ?, ?)',
        [item.options[index], index === item.answer, id],
      )
    }
    await client.query('COMMIT')
  } catch (error) {
    await client.query('ROLLBACK')
    throw error
  } finally {
    client.release()
  }
  return findQuiz(id)
}

async function removeQuiz(id) {
  const { rows } = await pool.query(
    `SELECT id_contenu AS contentId FROM question_quiz WHERE id_quiz = ?`,
    [id],
  )
  if (!rows[0]) return false
  await pool.query('DELETE FROM question_quiz WHERE id_quiz = ?', [id])
  return removeContentAndContribution(rows[0].contentId)
}

export async function list(resource) {
  if (resource === 'articles') {
    const { rows } = await pool.query(
      `SELECT ${articleColumns} ${articleJoins}
       WHERE cat.domaine IN ('Histoires', 'Musique', 'Savoir-faire', 'Traditions')
       ORDER BY c.date_creation DESC, c.id_contenu ASC`,
    )
    return rows
  }
  if (resource === 'places') return listPlaces()
  if (resource === 'quiz') return listQuiz()
  return null
}

export async function create(resource, item) {
  if (resource === 'articles') return createArticle(item)
  if (resource === 'places') return createPlace(item)
  if (resource === 'quiz') return createQuiz(item)
  return null
}

export async function update(resource, id, item) {
  if (resource === 'articles') return updateArticle(id, item)
  if (resource === 'places') return updatePlace(id, item)
  if (resource === 'quiz') return updateQuiz(id, item)
  return null
}

export async function find(resource, id) {
  if (resource === 'articles') return findArticle(id)
  if (resource === 'places') return findPlace(id)
  if (resource === 'quiz') return findQuiz(id)
  return null
}

export async function remove(resource, id) {
  if (resource === 'articles') {
    const item = await findArticle(id)
    return item && await removeContentAndContribution(id) ? { id } : null
  }
  if (resource === 'places') {
    const item = await findPlace(id)
    if (!item) return null
    await pool.query('DELETE FROM lieu WHERE id_lieu = ?', [id])
    return { id }
  }
  if (resource === 'quiz') return await removeQuiz(id) ? { id } : null
  return null
}
