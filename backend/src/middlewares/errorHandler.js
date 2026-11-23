export function errorHandler(error, _request, response, _next) {
  const statusCode = error.statusCode || 500
  if (statusCode >= 500) console.error(error)
  response.status(statusCode).json({ message: statusCode >= 500 ? 'Erreur interne du serveur.' : error.message })
}