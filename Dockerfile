# Image de production du backend Medusa East Market (déployée par Coolify).
FROM node:22-bookworm-slim AS builder
WORKDIR /app

# L'URL publique du backend est intégrée dans le bundle de l'admin au moment du build.
ARG MEDUSA_BACKEND_URL=https://api.eastmarket.africa
ENV MEDUSA_BACKEND_URL=$MEDUSA_BACKEND_URL

RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

COPY package.json yarn.lock .yarnrc.yml ./
COPY patches ./patches
# postinstall applique patch-package sur @medusajs/core-flows : node_modules est donc
# conservé tel quel dans l'image finale plutôt que réinstallé.
RUN yarn install --frozen-lockfile --network-timeout 600000

COPY . .
RUN yarn build

FROM node:22-bookworm-slim
WORKDIR /app

# ffmpeg sert au transcodage des vidéos courtes (src/modules/short-video/transcode.ts).
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg ca-certificates tini \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production \
    PORT=9000

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.medusa/server ./.medusa/server
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /app/.medusa/server
EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=5s --start-period=180s --retries=5 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||9000)+'/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

ENTRYPOINT ["/usr/bin/tini", "--", "docker-entrypoint.sh"]
