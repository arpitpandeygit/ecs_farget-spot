FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

RUN npm run build

EXPOSE 1337

ENV NODE_ENV=production

CMD ["npm", "start"]

