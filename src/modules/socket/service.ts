import { Server } from "socket.io"

// Singleton io instance accessible from REST routes
let _io: Server | null = null

export const getIO = () => _io
export const setIO = (io: Server) => { _io = io }

class SocketModuleService {
  getIO() { return _io }
}

export default SocketModuleService
