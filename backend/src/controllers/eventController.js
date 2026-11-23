import * as eventService from '../services/eventService.js'

export async function listPublished(_request, response) {
  response.json(await eventService.listPublishedEvents())
}

export async function listAll(_request, response) {
  response.json(await eventService.listEvents())
}

export async function submitProposal(request, response) {
  const event = await eventService.createProposal(request.body, request.userId)
  response.status(201).json(event)
}

export async function createPublished(request, response) {
  const event = await eventService.createPublishedEvent(request.body, request.userId)
  response.status(201).json(event)
}

export async function update(request, response) {
  response.json(await eventService.updateEvent(request.params.id, request.body))
}

export async function updateStatus(request, response) {
  response.json(await eventService.setEventStatus(request.params.id, request.body.status))
}

export async function remove(request, response) {
  response.json(await eventService.deleteEvent(request.params.id))
}