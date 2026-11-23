import { pool } from '../config/db.js'
import { findOrCreateCategory } from './categoryModel.js'
import { getOrCreateSystemUserId } from './userModel.js'

const columns = `
  e.id_evenement AS id, e.titre AS title,
  DATE_FORMAT(e.date_debut, '%Y-%m-%d') AS start,
  DATE_FORMAT(e.date_fin, '%Y-%m-%d') AS end,
  COALESCE(cat.nom, 'festival') AS category,
  COALESCE(e.lieu_texte, l.nom, '') AS location,
  COALESCE(e.description, '') AS description,
  COALESCE(e.image_url, '') AS \`imageUrl\`, '' AS \`imageName\`,
  CONCAT_WS(' ', u.prenom, u.nom) AS author, e.statut AS status,
  e.date_creation AS \`createdAt\`, e.date_moderation AS \`updatedAt\`
`
const joins = `
  FROM evenement e
  LEFT JOIN categorie cat ON cat.id_categorie = e.id_categorie
  LEFT JOIN lieu l ON l.id_lieu = e.id_lieu
  JOIN utilisateur u ON u.id_utilisateur = e.id_utilisateur_proposant
`

export async function createEvent(item, proposerId) {
  const categoryId = await findOrCreateCategory(item.category, 'Événement')
  const submittingUserId = proposerId || await getOrCreateSystemUserId()
  const { insertId } = await pool.query(
    `INSERT INTO evenement
       (titre, description, date_debut, date_fin, lieu_texte, image_url, statut, id_categorie, id_utilisateur_proposant)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      item.title, item.description, item.start, item.end || null, item.location,
      item.imageUrl || null, item.status, categoryId, submittingUserId,
    ],
  )
  return findEvent(insertId)
}

export async function listPublishedEvents() {
  const { rows } = await pool.query(
    `SELECT ${columns} ${joins} WHERE e.statut = 'Validé' ORDER BY e.date_debut ASC, e.date_creation DESC`,
  )
  return rows
}

export async function listEvents() {
  const { rows } = await pool.query(`SELECT ${columns} ${joins} ORDER BY e.date_creation DESC`)
  return rows
}

export async function findEvent(id) {
  const { rows } = await pool.query(
    `SELECT ${columns} ${joins} WHERE e.id_evenement = ?`,
    [id],
  )
  return rows[0] || null
}

export async function updateEvent(id, item) {
  const categoryId = await findOrCreateCategory(item.category, 'Événement')
  await pool.query(
    `UPDATE evenement
     SET titre = ?, description = ?, date_debut = ?, date_fin = ?, lieu_texte = ?,
         image_url = ?, id_categorie = ?
     WHERE id_evenement = ?`,
    [
      item.title, item.description, item.start, item.end || null, item.location,
      item.imageUrl || null, categoryId, id,
    ],
  )
  return findEvent(id)
}

export async function setEventStatus(id, status) {
  const moderatorId = await getOrCreateSystemUserId()
  await pool.query(
    `UPDATE evenement
     SET statut = ?, date_moderation = CURRENT_TIMESTAMP, id_utilisateur_moderateur = ?
     WHERE id_evenement = ?`,
    [status, moderatorId, id],
  )
  return findEvent(id)
}

export async function deleteEvent(id) {
  const event = await findEvent(id)
  if (!event) return null
  await pool.query('DELETE FROM evenement WHERE id_evenement = ?', [id])
  return event
}
