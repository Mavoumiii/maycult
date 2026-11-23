import * as adminModel from '../models/adminModel.js'
import { hashPassword } from './passwordService.js'
import { httpError } from './httpError.js'
import { normalizeEmail } from './authService.js'

function requiredText(value, field) {
  if (typeof value !== 'string' || !value.trim() || value.trim().length > 100) {
    throw httpError(400, `Le champ « ${field} » est obligatoire (100 caractères maximum).`)
  }
  return value.trim()
}

function parseAdminId(value) {
  if (!/^\d+$/.test(String(value))) throw httpError(400, 'Identifiant administrateur invalide.')
  const id = Number(value)
  if (!Number.isSafeInteger(id) || id < 1) throw httpError(400, 'Identifiant administrateur invalide.')
  return id
}

function publicAdmin(admin) {
  return {
    id: admin.id,
    nom: admin.nom,
    prenom: admin.prenom,
    email: admin.email,
    ...(admin.createdAt ? { createdAt: admin.createdAt } : {}),
  }
}

function validateInput(input, requirePassword) {
  if (!input || typeof input !== 'object' || Array.isArray(input)) {
    throw httpError(400, 'Les informations administrateur sont invalides.')
  }

  const result = {
    nom: requiredText(input.nom, 'nom'),
    prenom: requiredText(input.prenom, 'prenom'),
    email: normalizeEmail(input.email),
  }

  if (requirePassword || input.password !== undefined) {
    if (typeof input.password !== 'string' || input.password.length < 10 || input.password.length > 200) {
      throw httpError(400, 'Le mot de passe doit contenir entre 10 et 200 caractères.')
    }
    result.password = input.password
  }
  return result
}

export async function listAdmins() {
  return (await adminModel.listAdmins()).map(publicAdmin)
}

export async function createAdmin(input) {
  const admin = validateInput(input, true)
  try {
    const created = await adminModel.createAdmin({
      ...admin,
      passwordHash: await hashPassword(admin.password),
    })
    return publicAdmin(created)
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') throw httpError(409, 'Cette adresse e-mail est déjà utilisée par un administrateur.')
    throw error
  }
}

export async function updateAdmin(idValue, input) {
  const id = parseAdminId(idValue)
  const admin = validateInput(input, false)
  const existing = await adminModel.findAdminById(id)
  if (!existing) throw httpError(404, 'Administrateur introuvable.')

  try {
    const updated = await adminModel.updateAdmin(id, {
      ...admin,
      passwordHash: admin.password ? await hashPassword(admin.password) : undefined,
    })
    if (!updated) throw httpError(404, 'Administrateur introuvable.')
    return publicAdmin(updated)
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') throw httpError(409, 'Cette adresse e-mail est déjà utilisée par un administrateur.')
    throw error
  }
}

export async function deleteAdmin(idValue) {
  const id = parseAdminId(idValue)
  const deleted = await adminModel.deleteAdmin(id)
  if (deleted === null) throw httpError(404, 'Administrateur introuvable.')
  if (!deleted) throw httpError(409, 'Le dernier administrateur ne peut pas être supprimé.')
  return { id }
}
