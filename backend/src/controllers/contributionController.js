import * as contributionService from '../services/contributionService.js'

export async function create(request, response) {
  const contribution = await contributionService.createContribution(request.body, request.userId)
  response.status(201).json(contribution)
}

export async function listAll(_request, response) {
  response.json(await contributionService.listContributions())
}

export async function listPublished(_request, response) {
  response.json(await contributionService.listPublishedContributions())
}

export async function listContributors(_request, response) {
  response.json(await contributionService.listContributors())
}

export async function update(request, response) {
  response.json(await contributionService.updateContribution(request.params.id, request.body))
}

export async function updateStatus(request, response) {
  response.json(await contributionService.setContributionStatus(request.params.id, request.body.status))
}

export async function remove(request, response) {
  response.json(await contributionService.deleteContribution(request.params.id))
}