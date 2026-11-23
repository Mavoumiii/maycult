import { pool } from '../config/db.js'

export async function createUser({ nom, prenom, email, passwordHash }) {
  const { insertId } = await pool.query(
    `INSERT INTO utilisateur (nom, prenom, email, mot_de_passe_hash)
     VALUES (?, ?, ?, ?)`,
    [nom, prenom, email, passwordHash],
  )
  return findUserById(insertId)
}

export async function findUserByEmail(email) {
  const { rows } = await pool.query(
    `SELECT id_utilisateur AS id, nom, prenom, email, mot_de_passe_hash AS passwordHash
     FROM utilisateur WHERE email = ?`,
    [email],
  )
  return rows[0] || null
}

export async function findUserById(id) {
  const { rows } = await pool.query(
    `SELECT id_utilisateur AS id, nom, prenom, email
     FROM utilisateur WHERE id_utilisateur = ?`,
    [id],
  )
  return rows[0] || null
}

export async function getOrCreateSystemUserId() {
  await pool.query(
    `INSERT INTO utilisateur (nom, prenom, email, mot_de_passe_hash)
     VALUES ('Administration', 'MayCult', 'system@maycult.invalid', '!disabled!')
     ON DUPLICATE KEY UPDATE id_utilisateur = LAST_INSERT_ID(id_utilisateur)`,
  )
  const { rows } = await pool.query(
    'SELECT id_utilisateur AS id FROM utilisateur WHERE email = ?',
    ['system@maycult.invalid'],
  )
  if (!rows[0]) throw new Error('Impossible de retrouver le compte technique MayCult.')
  return rows[0].id
}
