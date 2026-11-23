import { createHmac, timingSafeEqual } from 'node:crypto'
import { env } from '../config/db.js'
import * as adminModel from '../models/adminModel.js'
import * as userModel from '../models/userModel.js'
import { httpError } from './httpError.js'
import { hashPassword, verifyPassword } from './passwordService.js'

const tokenLifetimeSeconds = 60 * 60 * 24 * 7

function sameSecret(provided, expected) {
  const providedBuffer = Buffer.from(provided || '')
  const expectedBuffer = Buffer.from(expected || '')
  return providedBuffer.length === expectedBuffer.length && timingSafeEqual(providedBuffer, expectedBuffer)
}

function publicUser(user) {
  const { passwordHash, ...safeUser } = user
  return { ...safeUser, name: `${user.prenom} ${user.nom}`.trim() }
}

function authSecret() {
  if (!env.authTokenSecret) throw httpError(503, 'Configurez AUTH_TOKEN_SECRET dans .env pour activer les comptes membres.')
  return env.authTokenSecret
}

function signToken(payload) {
  const encoded = Buffer.from(JSON.stringify(payload)).toString('base64url')
  const signature = createHmac('sha256', authSecret()).update(encoded).digest('base64url')
  return `${encoded}.${signature}`
}

export function verifyMemberToken(token) {
  if (!token || !env.authTokenSecret) return null
  const [encoded, signature, extra] = token.split('.')
  if (!encoded || !signature || extra) return null
  const expected = createHmac('sha256', env.authTokenSecret).update(encoded).digest()
  let actual
  try {
    actual = Buffer.from(signature, 'base64url')
  } catch {
    return null
  }
  if (actual.length !== expected.length || !timingSafeEqual(actual, expected)) return null
  try {
    const payload = JSON.parse(Buffer.from(encoded, 'base64url').toString('utf8'))
    if (!Number.isSafeInteger(payload.sub) || !Number.isSafeInteger(payload.exp) || payload.exp <= Math.floor(Date.now() / 1000)) return null
    return payload
  } catch {
    return null
  }
}

function createMemberToken(user) {
  const now = Math.floor(Date.now() / 1000)
  return signToken({ sub: Number(user.id), iat: now, exp: now + tokenLifetimeSeconds })
}

export function normalizeEmail(value) {
  if (typeof value !== 'string') throw httpError(400, 'Une adresse e-mail valide est obligatoire.')
  const email = value.trim().toLowerCase()
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 255) {
    throw httpError(400, 'Une adresse e-mail valide est obligatoire.')
  }
  return email
}

export function createAdminToken(admin) {
  const now = Math.floor(Date.now() / 1000)
  const payload = {
    sub: Number(admin.id),
    ver: Number(admin.sessionVersion),
    iat: now,
    exp: now + tokenLifetimeSeconds,
  }
  const encoded = Buffer.from(JSON.stringify(payload)).toString('base64url')
  const signature = createHmac('sha256', env.adminToken).update(encoded).digest('base64url')
  return `${encoded}.${signature}`
}

export function verifyAdminToken(token) {
  if (!token || !env.adminToken) return null
  const [encoded, signature, extra] = token.split('.')
  if (!encoded || !signature || extra) return null
  const expected = createHmac('sha256', env.adminToken).update(encoded).digest()
  let actual
  try {
    actual = Buffer.from(signature, 'base64url')
  } catch {
    return null
  }
  if (actual.length !== expected.length || !timingSafeEqual(actual, expected)) return null
  try {
    const payload = JSON.parse(Buffer.from(encoded, 'base64url').toString('utf8'))
    if (!Number.isSafeInteger(payload.sub) || !Number.isSafeInteger(payload.ver)
      || !Number.isSafeInteger(payload.exp) || payload.exp <= Math.floor(Date.now() / 1000)) return null
    return payload
  } catch {
    return null
  }
}

export async function loginAdmin(email, password) {
  if (!env.adminToken) {
    throw httpError(503, 'Configurez ADMIN_TOKEN dans .env pour signer les sessions administrateur.')
  }
  if (typeof password !== 'string' || !password) {
    throw httpError(400, 'L’adresse e-mail et le mot de passe sont obligatoires.')
  }

  const normalizedEmail = normalizeEmail(email)
  let admin = await adminModel.findAdminByEmail(normalizedEmail)

  if (!admin) {
    if (!env.adminEmail || !env.adminPassword) {
      throw httpError(503, 'Configurez ADMIN_EMAIL et ADMIN_PASSWORD dans .env pour initialiser le premier administrateur.')
    }
    if (!sameSecret(normalizedEmail, env.adminEmail.toLowerCase()) || !sameSecret(password, env.adminPassword)) {
      throw httpError(401, 'Identifiants administrateur incorrects.')
    }

    try {
      admin = await adminModel.createAdmin({
        nom: 'MayCult',
        prenom: 'Administrateur',
        email: normalizedEmail,
        passwordHash: await hashPassword(password),
      })
    } catch (error) {
      if (error.code !== 'ER_DUP_ENTRY') throw error
      admin = await adminModel.findAdminByEmail(normalizedEmail)
    }
  }

  if (!admin || !(await verifyPassword(password, admin.passwordHash))) {
    throw httpError(401, 'Identifiants administrateur incorrects.')
  }
  return {
    token: createAdminToken(admin),
    user: { id: admin.id, email: admin.email, name: `${admin.prenom} ${admin.nom}`.trim(), role: 'admin' },
  }
}

export async function registerMember(input) {
  const nom = typeof input.nom === 'string' ? input.nom.trim() : ''
  const prenom = typeof input.prenom === 'string' ? input.prenom.trim() : ''
  if (!nom || nom.length > 100 || !prenom || prenom.length > 100) {
    throw httpError(400, 'Le nom et le prénom sont obligatoires (100 caractères maximum).')
  }
  const email = normalizeEmail(input.email)
  if (typeof input.password !== 'string' || input.password.length < 10 || input.password.length > 200) {
    throw httpError(400, 'Le mot de passe doit contenir entre 10 et 200 caractères.')
  }
  authSecret()
  let user
  try {
    user = await userModel.createUser({ nom, prenom, email, passwordHash: await hashPassword(input.password) })
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') throw httpError(409, 'Cette adresse e-mail possède déjà un compte.')
    throw error
  }
  return { token: createMemberToken(user), user: publicUser(user) }
}

export async function loginMember(input) {
  const email = normalizeEmail(input.email)
  if (typeof input.password !== 'string' || !input.password) {
    throw httpError(400, 'L’adresse e-mail et le mot de passe sont obligatoires.')
  }
  const user = await userModel.findUserByEmail(email)
  if (!user || !(await verifyPassword(input.password, user.passwordHash))) {
    throw httpError(401, 'Adresse e-mail ou mot de passe incorrect.')
  }
  return { token: createMemberToken(user), user: publicUser(user) }
}

export async function getMember(token) {
  const payload = verifyMemberToken(token)
  if (!payload) throw httpError(401, 'Session membre invalide ou expirée.')
  const user = await userModel.findUserById(payload.sub)
  if (!user) throw httpError(401, 'Compte membre introuvable.')
  return publicUser(user)
}
