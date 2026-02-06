# Builder Stage
FROM node:18-alpine AS builder

RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build


# Production Stage
FROM node:18-alpine AS production

WORKDIR /app
ENV NODE_ENV=production

# Security: non-root user
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nextjs -u 1001

# Copy what is need to run
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

USER nextjs

EXPOSE 3001

CMD ["node", "server.js"]

# FROM node:18-alpine as base

# # install python
# RUN apk add --no-cache g++ make py3-pip libc6-compat
# WORKDIR /app
# COPY package*.json ./
# RUN npm install
# EXPOSE 3001

# # We put our common settings in the base stage, so that we can reuse it in other stages later on
# FROM base as builder
# WORKDIR /app
# RUN npm install
# COPY . .
# RUN npm run build


# FROM base as production
# WORKDIR /app
# # set NODE_ENV to production
# ENV NODE_ENV=production
# # run npm ci, which is trargeting for continuous integration, instead of npm install
# # RUN npm install

# # add a non-root user to run the app for security reasons.
# RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
# USER nextjs

# # we copied the assets needed from builder stage by calling COPY — from=builder
# COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
# # COPY --from=builder /app/node_modules ./node_modules old
# COPY --from=builder /app/package.json ./package.json
# COPY --from=builder /app/public ./public
# # COPY --from=builder /app/.next/standalone ./ new
# # COPY --from=builder /app/.next/static ./.next/static new

# #start our start our application
# CMD npm start

# FROM base as development
# ENV NODE_ENV=development
# # RUN npm install 
# COPY . .
# CMD npm run dev