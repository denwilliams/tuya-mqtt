FROM node:23-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json tsconfig.json ./
RUN npm ci
COPY ./src ./src
RUN npx tsc
RUN npx esbuild ./dist/main.js --bundle --platform=node --target=node23.11 --outfile=.sea/main.js
RUN echo '{ "main": ".sea/main.js", "output": ".sea/prep.blob", "disableExperimentalSEAWarning": true }' > .sea/config.json
RUN node --experimental-sea-config .sea/config.json
RUN cp /usr/local/bin/node /app/.sea/tuya-mqtt
RUN npx postject ".sea/tuya-mqtt" NODE_SEA_BLOB .sea/prep.blob --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2

FROM alpine:latest
WORKDIR /app
RUN apk update && apk add --no-cache libstdc++
COPY --from=builder /app/.sea/tuya-mqtt /app/tuya-mqtt

ARG MQTT_URI
ENV MQTT_URI=$MQTT_URI

ARG MQTT_PREFIX
ENV MQTT_PREFIX=$MQTT_PREFIX

ARG HTTP_PORT
ENV HTTP_PORT=$HTTP_PORT

ARG SERVICE_CONFIG
ENV SERVICE_CONFIG=$SERVICE_CONFIG

CMD ["node", "/app/dist/main.js"]
