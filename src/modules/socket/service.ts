import { Server } from "socket.io"

// Singleton io instance accessible from REST routes
let _io: Server | null = null

export const getIO = () => _io
export const setIO = (io: Server) => { _io = io }

// ─── Présence en mémoire ─────────────────────────────────────────────────────
// user_id (customer id ou vendor id) → nombre de sockets connectés
const _connections = new Map<string, number>()
// user_id → dernière déconnexion complète
const _lastSeen = new Map<string, Date>()

export type PresenceState = {
  user_id: string
  online: boolean
  last_seen_at: string | null
}

export const getPresence = (userId: string): PresenceState => ({
  user_id: userId,
  online: (_connections.get(userId) || 0) > 0,
  last_seen_at: _lastSeen.get(userId)?.toISOString() || null,
})

/** @returns true si c'est la première connexion (passage offline → online) */
export const trackConnect = (userId: string): boolean => {
  const count = (_connections.get(userId) || 0) + 1
  _connections.set(userId, count)
  return count === 1
}

/** @returns true si c'était la dernière connexion (passage online → offline) */
export const trackDisconnect = (userId: string): boolean => {
  const count = Math.max((_connections.get(userId) || 1) - 1, 0)
  if (count === 0) {
    _connections.delete(userId)
    _lastSeen.set(userId, new Date())
    return true
  }
  _connections.set(userId, count)
  return false
}

class SocketModuleService {
  getIO() { return _io }
}

export default SocketModuleService
