FROM ruby:3.1.2-alpine

LABEL maintainer=ferrari.marco@gmail.com

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --update --no-cache \
  autoconf \
  automake \
  build-base \
  ca-certificates \
  libtool \
  nasm \
  nodejs \
  npm \
  shadow \
  && update-ca-certificates

ARG UNAME=builder
ARG UID=1000
ARG GID=1000

# Use the binaries provided by the shadow packages to support UIDs and GIDs
# greater than 256000
RUN /usr/sbin/groupadd \
  --gid "${GID}" \
  "${UNAME}" \
  && /usr/sbin/useradd \
  --gid "${UNAME}" \
  --shell /bin/ash \
  --uid "$UID" \
  "${UNAME}" \
  && mkdir /home/"${UNAME}" \
  && chown -R "${UNAME}":"${UNAME}" /home/"${UNAME}"

ENV NODE_DEPENDENCIES_PATH=/usr
WORKDIR "${NODE_DEPENDENCIES_PATH}"
RUN chown -R ${UID}:${GID} "${NODE_DEPENDENCIES_PATH}"

USER "${UNAME}"

COPY --chown="${UNAME}":"${UNAME}" package.json package.json
COPY --chown="${UNAME}":"${UNAME}" package-lock.json package-lock.json

RUN npm install \
  && npm cache clean --force \
  && rm package.json package-lock.json

COPY --chown="${UNAME}":"${UNAME}" Gemfile Gemfile
COPY --chown="${UNAME}":"${UNAME}" Gemfile.lock Gemfile.lock

# Get the version specified in Gemfile (that may be automatically updated when new package versions are pushed)
# hadolint ignore=SC2046
RUN \
  gem install bundler:$(< Gemfile grep bundler | awk -F "'" '{print $4}') \
  && bundle config set --local system 'true' \
  && bundle install \
  && rm Gemfile Gemfile.lock

ENV NODE_PATH="${NODE_DEPENDENCIES_PATH}"/node_modules
ENV PATH="${NODE_PATH}/.bin":"${PATH}"

ENTRYPOINT ["npx", "--no-install", "gulp"]
EXPOSE 3000 3001
