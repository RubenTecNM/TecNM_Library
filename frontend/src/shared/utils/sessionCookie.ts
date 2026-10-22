const SESSION_COOKIE_NAME = 'session_exp'

function readCookie(name: string): string | undefined {
  const prefix = `${name}=`
  const entry = document.cookie
    .split(';')
    .map((cookie) => cookie.trim())
    .find((cookie) => cookie.startsWith(prefix))

  if (!entry) return undefined

  try {
    return decodeURIComponent(entry.slice(prefix.length))
  } catch {
    return undefined
  }
}

export function hasActiveSession(nowSeconds = Date.now() / 1000): boolean {
  const rawExpiration = readCookie(SESSION_COOKIE_NAME)
  if (!rawExpiration || !/^\d+$/.test(rawExpiration)) return false

  const expiration = Number(rawExpiration)
  return Number.isSafeInteger(expiration) && expiration > nowSeconds
}

export function clearSessionMarker(): void {
  document.cookie = `${SESSION_COOKIE_NAME}=; Max-Age=0; Path=/; SameSite=Lax; Secure`
}
