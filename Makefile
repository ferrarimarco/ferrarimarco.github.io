# Inspired by https://github.com/jessfraz/dotfiles

.PHONY: all
all: test build-docker-image ## Lint the code base, build the Docker image.

IMAGE_ID := "ferrarimarco/personal-website:latest"

.PHONY: build-docker-image
build-docker-image: ## Build the Docker image
	docker build \
		--build-arg UID="$(shell id -u)" \
		--build-arg GID="$(shell id -g)" \
		-t "$(IMAGE_ID)" .

.PHONY: test
test: jekyll-doctor ## Run tests

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -i
endif

.PHONY: build-serve-dev
build-serve-dev: build-docker-image ## Build and serve a development version of the website with LiveReload support
	docker run --rm -t $(DOCKER_FLAGS) \
		-v ""$(CURDIR)":/usr/app" \
		-p 3000:3000 \
		-p 3001:3001 \
		-w /usr/app \
		"$(IMAGE_ID)"

.PHONY: build-serve-prod
build-serve-prod: build-docker-image ## Build and serve a production version of the website with LiveReload support
	docker run --rm -t $(DOCKER_FLAGS) \
		-v ""$(CURDIR)":/usr/app" \
		-p 3000:3000 \
		-p 3001:3001 \
		-w /usr/app \
		"$(IMAGE_ID)" --prod

.PHONY: build-prod
build-prod: build-docker-image test ## Build a production version of the website
	docker run --rm -t $(DOCKER_FLAGS) \
		-v ""$(CURDIR)":/usr/app" \
		-w /usr/app \
		"$(IMAGE_ID)" build --prod

.PHONY: build-prod-serve-dest
build-prod-serve-dest: build-docker-image ## Build and serve (from the destination directory) a production version of the website with LiveReload support
	docker run --rm -t $(DOCKER_FLAGS) \
		-v ""$(CURDIR)":/usr/app" \
		-p 3000:3000 \
		-p 3001:3001 \
		-w /usr/app \
		"$(IMAGE_ID)" build-serve-dest --prod

.PHONY: jekyll-doctor
jekyll-doctor: build-docker-image ## Run jekyll doctor
	docker run --rm -t $(DOCKER_FLAGS) \
		-v ""$(CURDIR)":/usr/app" \
		-w /usr/app \
		"$(IMAGE_ID)" check

.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
