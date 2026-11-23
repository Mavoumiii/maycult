import * as adminModel from '../models/adminModel.js'
import { verifyAdminToken } from '../services/authService.js'

export async function requireAdmin(request, response, next) {
  const authorization = request.get('authorization') || ''
  const token = authorization.startsWith('Bearer ') ? authorization.slice(7) : ''
  const payload = verifyAdminToken(token)
  if (!payload) {
    return response.status(401).json({ message: 'Accès administrateur requis.' })
  }

  try {
    const admin = await adminModel.findAdminById(payload.sub)
    if (!admin || Number(admin.sessionVersion) !== payload.ver) {
      return response.status(401).json({ message: 'Session administrateur invalide ou révoquée.' })
    }
    request.adminId = Number(admin.id)
    return next()
  } catch (error) {
    return next(error)
  }
}