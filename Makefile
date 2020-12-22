# Inspired by https://github.com/jessfraz/dotfiles

.PHONY: all
all: test build-docker-image ## Lint the code base, build the Docker image.

.PHONY: build-docker-image
build-docker-image: ## Build the Docker image
	docker build -t "ferrarimarco/personal-website:latest" .

.PHONY: test
test: super-linter ## Run tests

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

IMAGE_ID := "ferrarimarco/personal-website:latest"

.PHONY: build-serve-dev
build-serve-dev: build-docker-image ## Build and serve a development version of the website with LiveReload support
	docker run --rm -t $(DOCKER_FLAGS) \
		-v ""$(CURDIR)":/usr/app" \
		-v /usr/app/node_modules/ \
		-p 3000:3000 \
		-p 3001:3001 \
		"$(IMAGE_ID)"

.PHONY: build-serve-prod
build-serve-prod: build-docker-image ## Build and serve a production version of the website with LiveReload support
	docker run --rm -t $(DOCKER_FLAGS) \
		-v ""$(CURDIR)":/usr/app" \
		-v /usr/app/node_modules/ \
		-p 3000:3000 \
		-p 3001:3001 \
		"$(IMAGE_ID)" --prod

.PHONY: build-prod
build-prod: build-docker-image ## Build a production version of the website
	docker run --rm -t $(DOCKER_FLAGS) \
		-v ""$(CURDIR)":/usr/app" \
		-v /usr/app/node_modules/ \
		"$(IMAGE_ID)" build --prod

.PHONY: build-prod-serve-dist
build-prod-serve-dist: build-docker-image ## Build and serve (from the `dist` directory) a production version of the website with LiveReload support
	docker run --rm -t $(DOCKER_FLAGS) \
		-v ""$(CURDIR)":/usr/app" \
		-v /usr/app/node_modules/ \
		-p 3000:3000 \
		-p 3001:3001 \
		"$(IMAGE_ID)" build-dist-serve --prod

.PHONY: deploy
deploy: test build-docker-image ## Deploy the site to production
	docker run --rm -t $(DOCKER_FLAGS) \
		-v ""$(CURDIR)":/usr/app" \
		-v "/usr/app/node_modules/" \
		-v ""$(CURDIR)"/id_rsa_ferrarimarco_github_io:/root/.ssh/id_rsa" \
		"$(IMAGE_ID)" deploy --prod

.PHONY: super-linter
super-linter: ## Run super-linter
	docker run --rm -t $(DOCKER_FLAGS) \
		-v "$(CURDIR)":/workspace \
		-w="/workspace" \
		-e ACTIONS_RUNNER_DEBUG=true \
		-e DEFAULT_WORKSPACE=/workspace \
		-e DISABLE_ERRORS=false \
		-e FILTER_REGEX_EXCLUDE=".*src/((_layouts|_includes)/.*.html|index.html|googlead.*html)" \
		-e LINTER_RULES_PATH=. \
		-e MULTI_STATUS=false \
		-e RUN_LOCAL=true \
		-e VALIDATE_ALL_CODEBASE=true \
		ghcr.io/github/super-linter:v3.13.1

.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
