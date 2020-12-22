FROM ruby:2.7.2-alpine

LABEL maintainer=ferrari.marco@gmail.com

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --update --no-cache \
  autoconf \
  automake \
  build-base \
  ca-certificates \
  git \
  libtool \
  nasm \
  nodejs \
  npm \
  openssh-client \
  wget \
  && update-ca-certificates \
  && ssh-keyscan github.com >> /etc/ssh/ssh_known_hosts

COPY package.json package.json

# Get the version specified in package.json (that may be automatically updated when new package versions are pushed)
# Don't enforce quoting here because version numbers are already quoted in package.json
# hadolint ignore=SC2046
RUN npm install -g fs-extra@$(< package.json grep fs-extra | awk -F '"' '{print $4}') \
  && npm install -g gulp-cli@$(< package.json grep gulp-cli | awk -F '"' '{print $4}')

COPY Gemfile Gemfile

# Get the version specified in Gemfile (that may be automatically updated when new package versions are pushed)
# hadolint ignore=SC2046
RUN \
  gem install bundler:$(< Gemfile grep bundler | awk -F "'" '{print $4}') \
  && bundle install

WORKDIR /usr/app

COPY package.json package.json
RUN npm install \
  && npm cache clean --force

COPY Gemfile Gemfile
RUN bundle install

RUN mkdir -p /root/.ssh

# Configure Git
RUN \
  git config --global user.email "ferrari.marco@gmail.com" \
  && git config --global user.name "Marco Ferrari" \
  && git config --global url."https://".insteadOf git://

ENTRYPOINT ["gulp"]
EXPOSE 3000 3001
