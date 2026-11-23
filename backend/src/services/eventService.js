import { randomUUID } from 'node:crypto'
import * as eventModel from '../models/eventModel.js'
import { httpError } from './httpError.js'

function requiredText(value, field) {
  if (typeof value !== 'string' || !value.trim()) throw httpError(400, `Le champ « ${field} » est obligatoire.`)
  return value.trim()
}

function validDate(value, field) {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) throw httpError(400, `Le champ « ${field} » doit être une date valide.`)
  const parsed = new Date(`${value}T00:00:00.000Z`)
  if (Number.isNaN(parsed.valueOf()) || parsed.toISOString().slice(0, 10) !== value) throw httpError(400, `Le champ « ${field} » doit être une date valide.`)
  return value
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

function normalizeEvent(input, defaults = {}) {
  const start = validDate(input.start || input.date, 'start')
  const end = validDate(input.end || input.date || start, 'end')
  if (end < start) throw httpError(400, 'La date de fin doit être après la date de début.')
  return {
    id: defaults.id || randomUUID(),
    title: requiredText(input.title, 'title'),
    start,
    end,
    category: typeof input.category === 'string' && input.category.trim() ? input.category.trim() : 'festival',
    location: requiredText(input.location, 'location'),
    description: requiredText(input.description, 'description'),
    imageUrl: optionalUrl(input.imageUrl, 'imageUrl'),
    imageName: typeof input.imageName === 'string' ? input.imageName : '',
    author: typeof input.author === 'string' && input.author.trim() ? input.author.trim() : defaults.author,
    status: defaults.status,
  }
}

export const listPublishedEvents = () => eventModel.listPublishedEvents()
export const listEvents = () => eventModel.listEvents()

export function createProposal(input, proposerId) {
  return eventModel.createEvent(normalizeEvent(input, { author: input.author || 'Membre', status: 'À valider' }), proposerId)
}

export function createPublishedEvent(input, proposerId) {
  return eventModel.createEvent(normalizeEvent(input, { author: 'Administration', status: 'Validé' }), proposerId)
}

export async function updateEvent(id, input) {
  const current = await eventModel.findEvent(id)
  if (!current) throw httpError(404, 'Événement introuvable.')
  const merged = normalizeEvent({ ...current, ...input }, { id, author: current.author, status: current.status })
  const event = await eventModel.updateEvent(id, merged)
  if (!event) throw httpError(404, 'Événement introuvable.')
  return event
}

export async function setEventStatus(id, status) {
  if (!['À valider', 'Validé', 'Refusé'].includes(status)) throw httpError(400, 'Statut d’événement invalide.')
  const event = await eventModel.setEventStatus(id, status)
  if (!event) throw httpError(404, 'Événement introuvable.')
  return event
}

export async function deleteEvent(id) {
  const event = await eventModel.deleteEvent(id)
  if (!event) throw httpError(404, 'Événement introuvable.')
  return event
}