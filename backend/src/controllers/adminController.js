import * as adminService from '../services/adminService.js'

export async function list(_request, response) {
  response.json(await adminService.listAdmins())
}

export async function create(request, response) {
  response.status(201).json(await adminService.createAdmin(request.body))
}

export async function update(request, response) {
  response.json(await adminService.updateAdmin(request.params.id, request.body))
}

export async function remove(request, response) {
  response.json(await adminService.deleteAdmin(request.params.id))
}
