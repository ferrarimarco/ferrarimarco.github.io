# Inspired by https://github.com/jessfraz/dotfiles

.PHONY: all
all: test build-docker-image ## Lint the code base, build the Docker image.

IMAGE_ID := ferrarimarco/personal-website:latest
TARGET_APP_DIR := /usr/src/app

.PHONY: build-docker-image
build-docker-image: ## Build the Docker image
	docker build \
		--build-arg UID="$(shell id -u)" \
		--build-arg GID="$(shell id -g)" \
		--network host \
		-t "$(IMAGE_ID)" .

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -i
endif

.PHONY: build-serve-prod
build-serve-prod: build-docker-image ## Build and serve a production version of the website with automatic reload support
	docker run --rm -t $(DOCKER_FLAGS) \
		--network host \
		--volume "$(CURDIR)":"$(TARGET_APP_DIR)" \
		"$(IMAGE_ID)" build-serve

.PHONY: build-prod
build-prod: build-docker-image ## Build a production version of the website
	docker run --rm -t $(DOCKER_FLAGS) \
		-v "$(CURDIR)":"$(TARGET_APP_DIR)" \
		"$(IMAGE_ID)" build

.PHONY: shell
shell: build-docker-image ## Open a shell in the container
	docker run --rm -t $(DOCKER_FLAGS) \
		--entrypoint /bin/ash \
		--volume "$(CURDIR)":"$(TARGET_APP_DIR)" \
		"$(IMAGE_ID)"

.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
