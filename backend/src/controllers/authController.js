import { getMember, loginAdmin, loginMember, registerMember } from '../services/authService.js'

export async function adminLogin(request, response) {
  response.json(await loginAdmin(request.body?.email, request.body?.password))
}

export async function memberRegister(request, response) {
  response.status(201).json(await registerMember(request.body || {}))
}

export async function memberLogin(request, response) {
  response.json(await loginMember(request.body || {}))
}

export async function memberMe(request, response) {
  const authorization = request.get('authorization') || ''
  const token = authorization.startsWith('Bearer ') ? authorization.slice(7) : ''
  response.json(await getMember(token))
}