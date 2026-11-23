import * as catalogService from '../services/catalogService.js'

export async function list(request, response) {
  response.json(await catalogService.list(request.params.resource))
}

export async function create(request, response) {
  response.status(201).json(await catalogService.create(request.params.resource, request.body))
}

export async function update(request, response) {
  response.json(await catalogService.update(request.params.resource, request.params.id, request.body))
}

export async function remove(request, response) {
  response.json(await catalogService.remove(request.params.resource, request.params.id))
}
