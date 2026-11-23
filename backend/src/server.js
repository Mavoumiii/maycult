import { app } from './app.js'
import { env, pool } from './config/db.js'

try {
  await pool.query('SELECT 1')
  app.listen(env.port, () => console.log(`CulVite API listening on http://localhost:${env.port}`))
} catch (error) {
  console.error('Connexion MariaDB impossible. Vérifiez les paramètres DB_* dans .env.', error.message)
  await pool.end()
  process.exitCode = 1
}
