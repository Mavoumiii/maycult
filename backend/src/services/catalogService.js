import * as catalogModel from '../models/catalogModel.js'
import { httpError } from './httpError.js'

const textFields = {
  articles: [
    'title', 'category', 'village', 'type', 'imageUrl', 'videoUrl', 'mediaType',
    'description', 'excerpt', 'content', 'origins', 'culturalMeaning', 'discoveryPlace',
  ],
  places: ['name', 'village', 'address', 'access', 'description', 'googleMapsUrl'],
}
const libraryCategories = new Set(['Histoires', 'Savoir-faire', 'Traditions'])
const resources = new Set([...Object.keys(textFields), 'quiz'])

function assertResource(resource) {
  if (!resources.has(resource)) throw httpError(404, 'Type de contenu introuvable.')
}

function requiredText(value, field) {
  if (typeof value !== 'string' || !value.trim()) throw httpError(400, `Le champ « ${field} » est obligatoire.`)
  return value.trim()
}

function optionalText(value, field) {
  if (value === undefined || value === null) return ''
  if (typeof value !== 'string') throw httpError(400, `Le champ « ${field} » doit être du texte.`)
  return value.trim()
}

function optionalUrl(value, field) {
  const text = optionalText(value, field)
  if (!text) return ''
  if (text.startsWith('/') && !text.startsWith('//')) return text
  try {
    const url = new URL(text)
    if (url.protocol === 'http:' || url.protocol === 'https:') return text
  } catch {
    throw httpError(400, `Le champ « ${field} » doit être une URL HTTP(S) valide.`)
  }
  throw httpError(400, `Le champ « ${field} » doit être une URL HTTP(S) valide.`)
}

function optionalGoogleMapsUrl(value) {
  const text = optionalText(value, 'googleMapsUrl')
  if (!text) return ''
  let url
  try {
    url = new URL(text)
  } catch {
    throw httpError(400, 'Le lien Google Maps doit être une URL valide.')
  }
  const host = url.hostname.toLowerCase()
  const isGoogleMapsHost = host === 'maps.app.goo.gl'
    || host === 'goo.gl'
    || host === 'maps.google.com'
    || host === 'google.com'
    || host.endsWith('.google.com')
  if (url.protocol !== 'https:' || !isGoogleMapsHost) {
    throw httpError(400, 'Le lien doit provenir de Google Maps.')
  }
  return text
}

function normalize(resource, input, id) {
  if (!input || typeof input !== 'object' || Array.isArray(input)) throw httpError(400, 'Le contenu envoyé est invalide.')
  if (resource === 'quiz') {
    const options = input.options
    const answer = Number(input.answer)
    if (!Array.isArray(options) || options.length < 2 || options.length > 6 || options.some((option) => typeof option !== 'string' || !option.trim())) {
      throw httpError(400, 'Une question doit contenir de 2 à 6 réponses non vides.')
    }
    if (!Number.isInteger(answer) || answer < 0 || answer >= options.length) {
      throw httpError(400, 'La réponse correcte sélectionnée est invalide.')
    }
    return {
      ...(id === undefined ? {} : { id }),
      question: requiredText(input.question, 'question'),
      options: options.map((option) => option.trim()),
      answer,
    }
  }

  const fields = textFields[resource]
  if (!fields) throw httpError(404, 'Type de contenu introuvable.')
  const required = resource === 'articles'
    ? ['title', 'category', 'type', 'description', 'content']
    : ['name', 'village', 'access']
  const item = id === undefined ? {} : { id }
  for (const field of fields) {
    item[field] = required.includes(field)
      ? requiredText(input[field], field)
      : field === 'imageUrl' || field === 'videoUrl'
        ? optionalUrl(input[field], field)
        : field === 'googleMapsUrl'
          ? optionalGoogleMapsUrl(input[field])
        : optionalText(input[field], field)
  }
  if (resource === 'articles') {
    if (!libraryCategories.has(item.category)) {
      throw httpError(400, 'La catégorie doit être Histoires, Savoir-faire ou Traditions.')
    }
    if (!item.mediaType) item.mediaType = 'video/mp4'
    if (!['video/mp4', 'audio/mpeg'].includes(item.mediaType)) {
      throw httpError(400, 'Le type de média doit être vidéo ou audio.')
    }
    item.theme = item.category
  }
  if (resource === 'places') {
    item.latitude = optionalCoordinate(input.latitude, 'latitude', -90, 90)
    item.longitude = optionalCoordinate(input.longitude, 'longitude', -180, 180)
  }
  return item
}

function optionalCoordinate(value, field, minimum, maximum) {
  if (value === undefined || value === null || value === '') return null
  const coordinate = Number(value)
  if (!Number.isFinite(coordinate) || coordinate < minimum || coordinate > maximum) {
    throw httpError(400, `Le champ « ${field} » doit être compris entre ${minimum} et ${maximum}.`)
  }
  return coordinate
}

export function list(resource) {
  assertResource(resource)
  return catalogModel.list(resource)
}

export async function create(resource, input) {
  assertResource(resource)
  const item = normalize(resource, input)
  return catalogModel.create(resource, item)
}

export async function update(resource, id, input) {
  assertResource(resource)
  const current = await catalogModel.find(resource, id)
  if (!current) throw httpError(404, 'Contenu introuvable.')
  const item = normalize(resource, { ...current, ...input }, id)
  return catalogModel.update(resource, id, item)
}

export async function remove(resource, id) {
  assertResource(resource)
  const item = await catalogModel.remove(resource, id)
  if (!item) throw httpError(404, 'Contenu introuvable.')
  return item
}
