FROM ruby:3.3.2

LABEL maintainer=ferrari.marco@gmail.com

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ENV PYTHONUNBUFFERED=1

RUN apt-get update \
  && apt-get --assume-yes --no-install-recommends install \
  build-essential \
  ca-certificates \
  make \
  npm \
  python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

ARG USERNAME=builder
ARG UID=1000
ARG GID=1000
ARG BUNDLE_RETRY=3

RUN groupadd \
  --gid "${GID}" \
  "${USERNAME}" \
  && useradd \
  --gid "${USERNAME}" \
  --shell /bin/bash \
  --uid "${UID}" \
  "${USERNAME}" \
  && mkdir /home/"${USERNAME}" \
  && chown -R "${USERNAME}":"${USERNAME}" /home/"${USERNAME}"

ENV APPLICATION_PATH_PARENT_PATH=/usr/src
ENV APPLICATION_PATH="${APPLICATION_PATH_PARENT_PATH}/app"
ENV APPLICATION_NODE_MODULES_PATH="${APPLICATION_PATH_PARENT_PATH}/node_modules"
WORKDIR "${APPLICATION_PATH}"
RUN mkdir --parent "${APPLICATION_PATH}" "${APPLICATION_NODE_MODULES_PATH}" \
  && chown -R ${UID}:${GID} "${APPLICATION_PATH}" "${APPLICATION_NODE_MODULES_PATH}"

USER "${USERNAME}"

COPY --chown="${USERNAME}":"${USERNAME}" Gemfile Gemfile
COPY --chown="${USERNAME}":"${USERNAME}" Gemfile.lock Gemfile.lock

RUN bundle install \
  --retry="${BUNDLE_RETRY}"

# Install npm modules one level above to avoid overriding them when mounting the source code.
# Note: this works because Node recursively looks for modules traversing the directory
# tree starting from the current directory and up.
WORKDIR "${APPLICATION_PATH_PARENT_PATH}"

COPY --chown="${USERNAME}":"${USERNAME}" package.json package.json
COPY --chown="${USERNAME}":"${USERNAME}" package-lock.json package-lock.json

RUN npm install

WORKDIR "${APPLICATION_PATH}"

EXPOSE 3000

ENTRYPOINT ["npm", "run"]
