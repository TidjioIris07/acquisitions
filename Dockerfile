# Multi-stage Dockerfile for Acquisitions Node.js Application

# Stage 1: Build & Dependencies
FROM node:24-alpine AS base

WORKDIR /app

# Install build essentials for native modules like bcrypt
RUN apk add --no-cache python3 make g++

COPY package*.json ./

# Install all dependencies
RUN npm ci

# Copy application source code
COPY . .

# Stage 2: Development target
FROM base AS development

ENV NODE_ENV=development

EXPOSE 3000

CMD ["npm", "run", "dev"]

# Stage 3: Production target
FROM node:20-alpine AS production

ENV NODE_ENV=production

WORKDIR /app

COPY --from=base /app/package*.json ./
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/src ./src
COPY --from=base /app/drizzle ./drizzle
COPY --from=base /app/drizzle.config.js ./drizzle.config.js

EXPOSE 3000

CMD ["npm", "start"]