import 'dotenv/config'
import mysql from 'mysql2/promise'
import { readdir, readFile } from 'node:fs/promises'
import { resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const clientOrigins = new Set([
  ...(process.env.CLIENT_ORIGIN || 'http://localhost:5173')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
  'https://mavoumiii.github.io',
])

export const env = {
  port: Number(process.env.PORT || 3000),
  clientOrigins: [...clientOrigins],
  databaseHost: process.env.DB_HOST || 'localhost',
  databasePort: Number(process.env.DB_PORT || 3306),
  databaseName: process.env.DB_NAME || 'culvite',
  databaseUser: process.env.DB_USER || 'root',
  databasePassword: process.env.DB_PASSWORD || '',
  databaseSsl: process.env.DB_SSL === 'true',
  authTokenSecret: process.env.AUTH_TOKEN_SECRET || '',
  adminEmail: process.env.ADMIN_EMAIL || '',
  adminPassword: process.env.ADMIN_PASSWORD || '',
  adminToken: process.env.ADMIN_TOKEN || '',
}

const mysqlPool = mysql.createPool({
  host: env.databaseHost,
  port: env.databasePort,
  database: env.databaseName,
  user: env.databaseUser,
  password: env.databasePassword,
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 10,
  ...(env.databaseSsl ? { ssl: { rejectUnauthorized: true } } : {}),
})

function normalizeResult(result) {
  if (Array.isArray(result)) return { rows: result, rowCount: result.length }
  return { rows: [], rowCount: result.affectedRows || 0, insertId: result.insertId }
}

export const pool = {
  async query(sql, values = []) {
    const [result] = await mysqlPool.query(sql, values)
    return normalizeResult(result)
  },
  async connect() {
    const connection = await mysqlPool.getConnection()
    return {
      async query(sql, values = []) {
        const [result] = await connection.query(sql, values)
        return normalizeResult(result)
      },
      release() {
        connection.release()
      },
    }
  },
  end() {
    return mysqlPool.end()
  },
}

async function runSql(client, sql) {
  for (const statement of sql.split(';').map((part) => part.trim()).filter(Boolean)) {
    await client.query(statement)
  }
}

async function initializeDatabase() {
  const applySeed = !process.argv.includes('--migrations-only')
  const databaseUrl = new URL('../../Database/', import.meta.url)
  const migrationsUrl = new URL('migrations/', databaseUrl)
  const migrationFiles = (await readdir(fileURLToPath(migrationsUrl)))
    .filter((name) => name.endsWith('.sql'))
    .sort()
  const seedFilename = 'api-seed-maycult-v1.sql'
  const seedUrl = new URL(seedFilename, databaseUrl)
  const seed = await readFile(fileURLToPath(seedUrl), 'utf8')

  await pool.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      filename VARCHAR(190) PRIMARY KEY,
      applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `)
  await pool.query(`
    CREATE TABLE IF NOT EXISTS database_seeds (
      filename VARCHAR(190) PRIMARY KEY,
      applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `)

  for (const filename of migrationFiles) {
    const { rows } = await pool.query(
      'SELECT 1 FROM schema_migrations WHERE filename = ?',
      [filename],
    )
    if (rows.length) continue

    const migrationUrl = new URL(filename, migrationsUrl)
    const migration = await readFile(fileURLToPath(migrationUrl), 'utf8')
    const migrationClient = await pool.connect()
    try {
      await runSql(migrationClient, migration)
      await migrationClient.query('INSERT INTO schema_migrations (filename) VALUES (?)', [filename])
    } finally {
      try {
        await migrationClient.query('SET FOREIGN_KEY_CHECKS = 1')
      } finally {
        migrationClient.release()
      }
    }
    console.log(`Migration appliquée : ${filename}`)
  }

  if (applySeed) {
    const seedClient = await pool.connect()
    try {
      await seedClient.query('START TRANSACTION')
      const { rows } = await seedClient.query(
        'SELECT 1 FROM database_seeds WHERE filename = ?',
        [seedFilename],
      )
      if (rows.length) {
        await seedClient.query('ROLLBACK')
      } else {
        await runSql(seedClient, seed)
        await seedClient.query('INSERT INTO database_seeds (filename) VALUES (?)', [seedFilename])
        await seedClient.query('COMMIT')
        console.log(`Données initiales appliquées : ${seedFilename}`)
      }
    } catch (error) {
      await seedClient.query('ROLLBACK')
      throw error
    } finally {
      seedClient.release()
    }
  } else {
    console.log('Chargement du seed ignoré (--migrations-only).')
  }

  console.log(applySeed ? 'Migrations et données initiales vérifiées.' : 'Migrations vérifiées.')
}

const isMain = process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)

if (isMain) {
  try {
    await initializeDatabase()
  } catch (error) {
    console.error('Impossible d’initialiser la base MariaDB.', error.message)
    process.exitCode = 1
  } finally {
    await pool.end()
  }
}
