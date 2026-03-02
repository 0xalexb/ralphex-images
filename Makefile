DOCKER_IMAGE ?= ghcr.io/0xalexb/ralphex-python
UV_VERSION ?= 0.10.6
RUFF_VERSION ?= 0.15.3
RALPHEX_VERSION ?= latest
PYTHON_VERSIONS := 3.11 3.12 3.13
LATEST_VERSION := 3.13

.PHONY: build build-one push

build:
	@for ver in $(PYTHON_VERSIONS); do \
		echo "Building $(DOCKER_IMAGE):py$$ver"; \
		docker build --build-arg PYTHON_VERSION=$$ver --build-arg UV_VERSION=$(UV_VERSION) --build-arg RUFF_VERSION=$(RUFF_VERSION) --build-arg RALPHEX_VERSION=$(RALPHEX_VERSION) -t $(DOCKER_IMAGE):py$$ver . || exit 1; \
		docker tag $(DOCKER_IMAGE):py$$ver $(DOCKER_IMAGE):r$(RALPHEX_VERSION)-py$$ver || exit 1; \
		if [ -n "$(VERSION)" ]; then \
			docker tag $(DOCKER_IMAGE):py$$ver $(DOCKER_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$$ver || exit 1; \
		fi; \
	done
	docker tag $(DOCKER_IMAGE):py$(LATEST_VERSION) $(DOCKER_IMAGE):latest

build-one:
	@if [ -z "$(PYTHON_VERSION)" ]; then echo "Error: PYTHON_VERSION is required, e.g. make build-one PYTHON_VERSION=3.13"; exit 1; fi
	docker build --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg UV_VERSION=$(UV_VERSION) --build-arg RUFF_VERSION=$(RUFF_VERSION) --build-arg RALPHEX_VERSION=$(RALPHEX_VERSION) -t $(DOCKER_IMAGE):py$(PYTHON_VERSION) .
	docker tag $(DOCKER_IMAGE):py$(PYTHON_VERSION) $(DOCKER_IMAGE):r$(RALPHEX_VERSION)-py$(PYTHON_VERSION) || exit 1
	@if [ -n "$(VERSION)" ]; then \
		docker tag $(DOCKER_IMAGE):py$(PYTHON_VERSION) $(DOCKER_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$(PYTHON_VERSION) || exit 1; \
	fi

push:
	@for ver in $(PYTHON_VERSIONS); do \
		echo "Pushing $(DOCKER_IMAGE):py$$ver"; \
		docker push $(DOCKER_IMAGE):py$$ver || exit 1; \
		echo "Pushing $(DOCKER_IMAGE):r$(RALPHEX_VERSION)-py$$ver"; \
		docker push $(DOCKER_IMAGE):r$(RALPHEX_VERSION)-py$$ver || exit 1; \
		if [ -n "$(VERSION)" ]; then \
			echo "Pushing $(DOCKER_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$$ver"; \
			docker push $(DOCKER_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$$ver || exit 1; \
		fi; \
	done
	@if docker image inspect $(DOCKER_IMAGE):latest >/dev/null 2>&1; then \
		docker push $(DOCKER_IMAGE):latest; \
	else \
		echo "Skipping latest: tag not found (run 'make build' to create it)"; \
	fi
