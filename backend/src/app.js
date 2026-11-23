import express from 'express'
import cors from 'cors'
import { env } from './config/db.js'
import { errorHandler } from './middlewares/errorHandler.js'
import { apiRouter } from './router/apiRouter.js'

export const app = express()

app.use(cors({ origin: env.clientOrigins }))
app.use(express.json({ limit: '1mb' }))
app.use('/api', apiRouter)
app.use((_request, response) => response.status(404).json({ message: 'Route introuvable.' }))
app.use(errorHandler)

app.get('/api/health', (_request, response) => response.status(200).json({ message: 'API en bonne santé.' }))

export default app
