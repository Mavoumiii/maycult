import * as adminModel from '../models/adminModel.js'
import { getOrCreateSystemUserId } from '../models/userModel.js'
import { getMember, verifyAdminToken, verifyMemberToken } from '../services/authService.js'

export async function requireMember(request, response, next) {
  const authorization = request.get('authorization') || ''
  const token = authorization.startsWith('Bearer ') ? authorization.slice(7) : ''

  const adminPayload = verifyAdminToken(token)
  if (adminPayload) {
    const admin = await adminModel.findAdminById(adminPayload.sub)
    if (admin && Number(admin.sessionVersion) === adminPayload.ver) {
      request.userId = await getOrCreateSystemUserId()
      return next()
    }
    return response.status(401).json({ message: 'Session administrateur invalide ou révoquée.' })
  }

  const payload = verifyMemberToken(token)
  if (!payload) return response.status(401).json({ message: 'Connexion membre requise.' })

  const user = await getMember(token)
  request.userId = user.id
  request.memberToken = token
  return next()
}
