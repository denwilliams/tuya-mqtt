FROM node:23-alpine
WORKDIR /app
COPY package.json package-lock.json tsconfig.json ./
RUN npm ci
COPY ./src ./src
RUN npx tsc

RUN npm prune --production

ARG MQTT_URI
ENV MQTT_URI=$MQTT_URI

ARG MQTT_PREFIX
ENV MQTT_PREFIX=$MQTT_PREFIX

ARG HTTP_PORT
ENV HTTP_PORT=$HTTP_PORT

ARG SERVICE_CONFIG
ENV SERVICE_CONFIG=$SERVICE_CONFIG

CMD ["node", "/app/dist/main.js"]
