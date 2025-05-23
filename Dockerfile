#=== Stage 0: Base ===
FROM --platform=$BUILDPLATFORM node:22.14-alpine AS base
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Building on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log

# Read more: https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

# Read more: https://pnpm.io/npmrc#store-dir to under stand PNPM store-dir
ARG PNPM_HOME
ENV PATH="$PATH:$PNPM_HOME"
RUN corepack enable
RUN corepack prepare pnpm@9.15.4 --activate

WORKDIR /app

#=== Stage 1: Build ===
FROM base AS builder
COPY . .
RUN --mount=type=cache,id=pnpm,target="$PNPM_HOME/store" pnpm install --frozen-lockfile
ENV NODE_ENV production
ENV PORT=5173

EXPOSE 5173
RUN pnpm build

CMD ["pnpm", "preview", "--host", "--port", "5173"]