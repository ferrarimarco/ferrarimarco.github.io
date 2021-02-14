FROM ruby:3.0.0-alpine

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
  && update-ca-certificates

ARG UNAME=builder
ARG UID=1000
ARG GID=1000

RUN addgroup \
  --gid "${GID}" \
  "${UNAME}" \
  && adduser \
  --disabled-password \
  --gecos "" \
  --ingroup "${UNAME}" \
  --shell /bin/ash \
  --uid "$UID" \
  "${UNAME}"

COPY package.json package.json

# Get the version specified in package.json (that may be automatically updated when new package versions are pushed)
# Don't enforce quoting here because version numbers are already quoted in package.json
# hadolint ignore=SC2046
RUN npm install -g fs-extra@$(< package.json grep fs-extra | awk -F '"' '{print $4}') \
  && npm install -g gulp-cli@$(< package.json grep gulp-cli | awk -F '"' '{print $4}')

USER "${UNAME}"

RUN npm install \
  && npm cache clean --force \
  && rm package.json

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

# Get the version specified in Gemfile (that may be automatically updated when new package versions are pushed)
# hadolint ignore=SC2046
RUN \
  gem install bundler:$(< Gemfile grep bundler | awk -F "'" '{print $4}') \
  && bundle config set --local system 'true' \
  && bundle install \
  && rm Gemfile Gemfile.lock

ENTRYPOINT ["gulp"]
EXPOSE 3000 3001
