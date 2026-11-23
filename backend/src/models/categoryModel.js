import { pool } from '../config/db.js'

export async function findOrCreateCategory(name, domain = '', description = '') {
  const normalizedName = String(name || '').trim() || 'Sans catégorie'
  const normalizedDomain = String(domain || '').trim()
  await pool.query(
    `INSERT INTO categorie (nom, domaine, description) VALUES (?, ?, ?)
     ON DUPLICATE KEY UPDATE id_categorie = LAST_INSERT_ID(id_categorie)`,
    [normalizedName, normalizedDomain, description || null],
  )
  const { rows } = await pool.query(
    'SELECT id_categorie AS id FROM categorie WHERE nom = ? AND domaine = ?',
    [normalizedName, normalizedDomain],
  )
  if (!rows[0]) throw new Error(`Impossible de retrouver la catégorie « ${normalizedName} ».`)
  return rows[0].id
}
