FROM ruby:3.1.2-alpine

LABEL maintainer=ferrari.marco@gmail.com

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache \
  build-base \
  ca-certificates \
  make \
  npm \
  python3 \
  py3-pip \
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

ENV APPLICATION_PATH_PARENT_PATH=/usr/src
ENV APPLICATION_PATH="${APPLICATION_PATH_PARENT_PATH}/app"
ENV APPLICATION_NODE_MODULES_PATH="${APPLICATION_PATH_PARENT_PATH}/node_modules"
WORKDIR "${APPLICATION_PATH}"
RUN mkdir -p "${APPLICATION_PATH}" "${APPLICATION_NODE_MODULES_PATH}" \
  && chown -R ${UID}:${GID} "${APPLICATION_PATH}" "${APPLICATION_NODE_MODULES_PATH}"

USER "${USERNAME}"

COPY --chown="${USERNAME}":"${USERNAME}" Gemfile Gemfile
COPY --chown="${USERNAME}":"${USERNAME}" Gemfile.lock Gemfile.lock

RUN bundle install

# Install npm modules one level above to avoid overriding them when mounting the source code.
# Note: this works because Node recursively looks for modules traversing the directory
# tree starting from the current directory and up.
WORKDIR "${APPLICATION_PATH_PARENT_PATH}"

COPY --chown="${USERNAME}":"${USERNAME}" package.json package.json
COPY --chown="${USERNAME}":"${USERNAME}" package-lock.json package-lock.json

RUN npm install

WORKDIR "${APPLICATION_PATH}"

EXPOSE 3000 3001

ENTRYPOINT ["npm", "run"]
