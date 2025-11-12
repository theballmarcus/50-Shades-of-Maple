FROM node:20 AS base

RUN mkdir -p /app

WORKDIR /app

COPY . /app
# RUN npm ci --omit=dev 
WORKDIR /app/src

RUN npm install

ENV NODE_ENV=production \
    PORT=3000

EXPOSE 3000
CMD ["node", "server.js"]