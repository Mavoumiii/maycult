import { randomBytes, scrypt as scryptCallback, timingSafeEqual } from 'node:crypto'
import { promisify } from 'node:util'

const scrypt = promisify(scryptCallback)

export async function hashPassword(password) {
  const salt = randomBytes(16).toString('hex')
  const hash = await scrypt(password, salt, 64)
  return `scrypt$${salt}$${hash.toString('hex')}`
}

export async function verifyPassword(password, encodedHash) {
  const [algorithm, salt, hexHash] = String(encodedHash || '').split('$')
  if (algorithm !== 'scrypt' || !salt || !/^[a-f\d]{128}$/i.test(hexHash || '')) return false
  const expected = Buffer.from(hexHash, 'hex')
  const actual = await scrypt(password, salt, expected.length)
  return timingSafeEqual(actual, expected)
}
