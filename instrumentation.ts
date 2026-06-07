import http from "http";
import { Server as IOServer, type ServerOptions } from "socket.io";

declare global {
  // eslint-disable-next-line no-var
  var __medusaIo: IOServer | undefined;
  // eslint-disable-next-line no-var
  var __medusaIoPatched: boolean | undefined;
}

function parseOrigins(value: string | undefined): string[] | boolean {
  if (!value || value.trim() === "" || value.trim() === "*") return true;
  return value.split(",").map((s) => s.trim()).filter(Boolean);
}

const log = (msg: string, ...rest: unknown[]) =>
  console.log(`[Socket.io Global] ${msg}`, ...rest);

export function register() {
  if (process.env.MEDUSA_WORKER_MODE === "worker") {
    log("worker mode: skip init");
    return;
  }
  if (globalThis.__medusaIoPatched) {
    log("already patched, skip");
    return;
  }
  globalThis.__medusaIoPatched = true;

  log("patching http.createServer…");
  const original = http.createServer.bind(http);

  // @ts-ignore
  http.createServer = function patchedCreateServer(...args: unknown[]) {
    const server = (original as any)(...args) as http.Server;
    log("http.Server captured");

    try {
      const path = "/socket.io";
      const combinedCors = [
        process.env.STORE_CORS || "",
        process.env.ADMIN_CORS || "",
        process.env.AUTH_CORS || ""
      ].filter(Boolean).join(",");

      const corsOrigin = parseOrigins(combinedCors);
      const options: Partial<ServerOptions> = {
        path,
        cors: { origin: corsOrigin, credentials: true },
        transports: ["websocket", "polling"],
      };

      const io = new IOServer(server, options);
      globalThis.__medusaIo = io;

      log(`initialized · path=${path}`);

      const shutdown = () => {
        log("closing io…");
        try { io.close(); } catch { /* noop */ }
      };
      process.once("SIGTERM", shutdown);
      process.once("SIGINT", shutdown);
    } catch (err) {
      console.error("[socket.io] init failed:", err);
    } finally {
      http.createServer = original; // restore — only patch the first call
    }

    return server;
  };
}
