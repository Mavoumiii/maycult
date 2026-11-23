import { pool } from '../config/db.js'

export async function findAdminByEmail(email) {
  const { rows } = await pool.query(
    `SELECT id_administrateur AS id, nom, prenom, email,
            mot_de_passe_hash AS passwordHash, session_version AS sessionVersion
     FROM administrateur WHERE email = ?`,
    [email],
  )
  return rows[0] || null
}

export async function findAdminById(id) {
  const { rows } = await pool.query(
    `SELECT id_administrateur AS id, nom, prenom, email,
            session_version AS sessionVersion
     FROM administrateur WHERE id_administrateur = ?`,
    [id],
  )
  return rows[0] || null
}

export async function listAdmins() {
  const { rows } = await pool.query(
    `SELECT id_administrateur AS id, nom, prenom, email,
            date_creation AS createdAt
     FROM administrateur ORDER BY nom ASC, prenom ASC, id_administrateur ASC`,
  )
  return rows
}

export async function createAdmin({ nom, prenom, email, passwordHash }) {
  await pool.query(
    `INSERT INTO administrateur (nom, prenom, email, mot_de_passe_hash)
     VALUES (?, ?, ?, ?)`,
    [nom, prenom, email, passwordHash],
  )
  return findAdminByEmail(email)
}

export async function updateAdmin(id, { nom, prenom, email, passwordHash }) {
  const fields = ['nom = ?', 'prenom = ?', 'email = ?']
  const values = [nom, prenom, email]
  if (passwordHash) {
    fields.push('mot_de_passe_hash = ?', 'session_version = session_version + 1')
    values.push(passwordHash)
  }
  values.push(id)
  await pool.query(`UPDATE administrateur SET ${fields.join(', ')} WHERE id_administrateur = ?`, values)
  return findAdminById(id)
}

export async function deleteAdmin(id) {
  const connection = await pool.connect()
  try {
    await connection.query('START TRANSACTION')
    const { rows: admins } = await connection.query(
      'SELECT id_administrateur FROM administrateur FOR UPDATE',
    )
    if (!admins.some((admin) => Number(admin.id_administrateur) === id)) {
      await connection.query('ROLLBACK')
      return null
    }
    if (admins.length <= 1) {
      await connection.query('ROLLBACK')
      return false
    }
    await connection.query('DELETE FROM administrateur WHERE id_administrateur = ?', [id])
    await connection.query('COMMIT')
    return true
  } catch (error) {
    await connection.query('ROLLBACK')
    throw error
  } finally {
    connection.release()
  }
}
