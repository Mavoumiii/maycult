import { randomUUID } from 'node:crypto'
import { pool } from '../config/db.js'

export async function findOrCreateVillageId(name) {
  if (name !== undefined && name !== null && typeof name !== 'string') {
    throw new TypeError('Le nom du village doit être du texte.')
  }
  const normalizedName = typeof name === 'string' ? name.trim() : ''
  if (!normalizedName) return null

  await pool.query(
    'INSERT INTO villages (id, name) VALUES (?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name)',
    [randomUUID(), normalizedName],
  )
  const { rows } = await pool.query('SELECT id FROM villages WHERE name = ?', [normalizedName])
  if (!rows[0]) throw new Error(`Impossible de retrouver le village « ${normalizedName} » après son enregistrement.`)
  return rows[0].id
}
