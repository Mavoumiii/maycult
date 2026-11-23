import * as contributionModel from '../models/contributionModel.js'
import { httpError } from './httpError.js'

function requiredText(value, field) {
  if (typeof value !== 'string' || !value.trim()) throw httpError(400, `Le champ « ${field} » est obligatoire.`)
  return value.trim()
}

function optionalUrl(value, field) {
  if (value === undefined || value === null || value === '') return ''
  if (typeof value !== 'string') throw httpError(400, `Le champ « ${field} » doit être une URL HTTP(S) valide.`)
  if (!value.trim()) return ''
  const text = value.trim()
  if (text.startsWith('/') && !text.startsWith('//')) return text
  try {
    const url = new URL(text)
    if (url.protocol === 'http:' || url.protocol === 'https:') return text
  } catch {
    throw httpError(400, `Le champ « ${field} » doit être une URL HTTP(S) valide.`)
  }
  throw httpError(400, `Le champ « ${field} » doit être une URL HTTP(S) valide.`)
}

export function createContribution(input, userId) {
  if (input.charterAccepted !== true) throw httpError(400, 'Vous devez accepter la charte de contribution.')
  return contributionModel.createContribution({
    title: requiredText(input.title, 'title'),
    type: typeof input.type === 'string' && input.type.trim() ? input.type.trim() : 'Récit',
    village: typeof input.village === 'string' ? input.village.trim() : '',
    content: requiredText(input.content, 'content'),
    charterAccepted: input.charterAccepted === true,
    imageUrl: optionalUrl(input.imageUrl, 'imageUrl'),
    mediaUrl: optionalUrl(input.mediaUrl, 'mediaUrl'),
    youtubeUrl: optionalUrl(input.youtubeUrl, 'youtubeUrl'),
    status: 'À relire',
  }, userId)
}

export const listContributions = () => contributionModel.listContributions()
export const listPublishedContributions = () => contributionModel.listPublishedContributions()
export const listContributors = () => contributionModel.listContributors()

export async function updateContribution(id, input) {
  const contribution = await contributionModel.updateContribution(id, input)
  if (!contribution) throw httpError(404, 'Contribution introuvable.')
  return contribution
}

export async function setContributionStatus(id, status) {
  if (!['À relire', 'Validé', 'Refusé'].includes(status)) throw httpError(400, 'Statut de contribution invalide.')
  const contribution = await contributionModel.setContributionStatus(id, status)
  if (!contribution) throw httpError(404, 'Contribution introuvable.')
  return contribution
}

export async function deleteContribution(id) {
  const contribution = await contributionModel.deleteContribution(id)
  if (!contribution) throw httpError(404, 'Contribution introuvable.')
  return contribution
}