FROM ruby:3.1.2-alpine

LABEL maintainer=ferrari.marco@gmail.com

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache \
  build-base \
  ca-certificates \
  make \
  npm \
  shadow \
  && update-ca-certificates

ARG USERNAME=builder
ARG UID=1000
ARG GID=1000

# Use the binaries provided by the shadow packages to support UIDs and GIDs
# greater than 256000
RUN /usr/sbin/groupadd \
  --gid "${GID}" \
  "${USERNAME}" \
  && /usr/sbin/useradd \
  --gid "${USERNAME}" \
  --shell /bin/ash \
  --uid "${UID}" \
  "${USERNAME}" \
  && mkdir /home/"${USERNAME}" \
  && chown -R "${USERNAME}":"${USERNAME}" /home/"${USERNAME}"

ENV APPLICATION_PATH=/usr/src/app
WORKDIR "${APPLICATION_PATH}"
RUN mkdir -p "${APPLICATION_PATH}" \
  && chown -R ${UID}:${GID} "${APPLICATION_PATH}"

USER "${USERNAME}"

COPY --chown="${USERNAME}":"${USERNAME}" Gemfile Gemfile
COPY --chown="${USERNAME}":"${USERNAME}" Gemfile.lock Gemfile.lock

RUN bundle install

COPY --chown="${USERNAME}":"${USERNAME}" package.json package.json
COPY --chown="${USERNAME}":"${USERNAME}" package-lock.json package-lock.json

RUN rm -rf node_modules \
  && npm install

EXPOSE 3000 3001

ENTRYPOINT ["npm", "run"]
