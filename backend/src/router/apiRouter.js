import { Router } from 'express'
import { adminLogin, memberLogin, memberMe, memberRegister } from '../controllers/authController.js'
import * as adminController from '../controllers/adminController.js'
import * as contributionController from '../controllers/contributionController.js'
import * as catalogController from '../controllers/catalogController.js'
import * as eventController from '../controllers/eventController.js'
import { asyncHandler } from '../middlewares/asyncHandler.js'
import { requireAdmin } from '../middlewares/requireAdmin.js'
import { requireMember } from '../middlewares/requireMember.js'
import { pool } from '../config/db.js'

export const apiRouter = Router()

apiRouter.get('/health', asyncHandler(async (_request, response) => {
  await pool.query('SELECT 1')
  response.json({ status: 'ok', database: 'connected' })
}))

apiRouter.post('/admin/login', asyncHandler(adminLogin))
apiRouter.get('/admin/admins', requireAdmin, asyncHandler(adminController.list))
apiRouter.post('/admin/admins', requireAdmin, asyncHandler(adminController.create))
apiRouter.put('/admin/admins/:id', requireAdmin, asyncHandler(adminController.update))
apiRouter.delete('/admin/admins/:id', requireAdmin, asyncHandler(adminController.remove))
apiRouter.post('/auth/register', asyncHandler(memberRegister))
apiRouter.post('/auth/login', asyncHandler(memberLogin))
apiRouter.get('/auth/me', asyncHandler(memberMe))

apiRouter.get('/catalog/:resource', asyncHandler(catalogController.list))
apiRouter.post('/catalog/:resource', requireAdmin, asyncHandler(catalogController.create))
apiRouter.put('/catalog/:resource/:id', requireAdmin, asyncHandler(catalogController.update))
apiRouter.delete('/catalog/:resource/:id', requireAdmin, asyncHandler(catalogController.remove))

apiRouter.get('/events', asyncHandler(eventController.listPublished))
apiRouter.post('/events/proposals', asyncHandler(requireMember), asyncHandler(eventController.submitProposal))
apiRouter.post('/events', requireAdmin, asyncHandler(eventController.createPublished))
apiRouter.get('/admin/events', requireAdmin, asyncHandler(eventController.listAll))
apiRouter.patch('/admin/events/:id/status', requireAdmin, asyncHandler(eventController.updateStatus))
apiRouter.put('/events/:id', requireAdmin, asyncHandler(eventController.update))
apiRouter.delete('/events/:id', requireAdmin, asyncHandler(eventController.remove))

apiRouter.get('/contributions/published', asyncHandler(contributionController.listPublished))
apiRouter.post('/contributions', asyncHandler(requireMember), asyncHandler(contributionController.create))
apiRouter.get('/contributions', requireAdmin, asyncHandler(contributionController.listAll))
apiRouter.patch('/contributions/:id/status', requireAdmin, asyncHandler(contributionController.updateStatus))
apiRouter.put('/contributions/:id', requireAdmin, asyncHandler(contributionController.update))
apiRouter.delete('/contributions/:id', requireAdmin, asyncHandler(contributionController.remove))

apiRouter.get('/contributors', asyncHandler(contributionController.listContributors))