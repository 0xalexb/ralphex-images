PYTHON_IMAGE ?= ghcr.io/0xalexb/ralphex-python
GO_IMAGE ?= ghcr.io/0xalexb/ralphex-go
UV_VERSION ?= 0.10.6
RUFF_VERSION ?= 0.15.3
RALPHEX_VERSION ?= latest
RALPHEX_GO_VERSION ?= latest
PYTHON_VERSIONS := 3.11 3.12 3.13

.PHONY: build build-python build-one build-go push push-python push-go

build: build-python build-go

build-python:
	@for ver in $(PYTHON_VERSIONS); do \
		echo "Building $(PYTHON_IMAGE):py$$ver"; \
		docker build --build-arg PYTHON_VERSION=$$ver --build-arg UV_VERSION=$(UV_VERSION) --build-arg RUFF_VERSION=$(RUFF_VERSION) --build-arg RALPHEX_VERSION=$(RALPHEX_VERSION) -t $(PYTHON_IMAGE):py$$ver docker-python/ || exit 1; \
		docker tag $(PYTHON_IMAGE):py$$ver $(PYTHON_IMAGE):r$(RALPHEX_VERSION)-py$$ver || exit 1; \
		if [ -n "$(VERSION)" ]; then \
			docker tag $(PYTHON_IMAGE):py$$ver $(PYTHON_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$$ver || exit 1; \
		fi; \
	done

build-one:
	@if [ -z "$(PYTHON_VERSION)" ]; then echo "Error: PYTHON_VERSION is required, e.g. make build-one PYTHON_VERSION=3.13"; exit 1; fi
	docker build --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg UV_VERSION=$(UV_VERSION) --build-arg RUFF_VERSION=$(RUFF_VERSION) --build-arg RALPHEX_VERSION=$(RALPHEX_VERSION) -t $(PYTHON_IMAGE):py$(PYTHON_VERSION) docker-python/
	docker tag $(PYTHON_IMAGE):py$(PYTHON_VERSION) $(PYTHON_IMAGE):r$(RALPHEX_VERSION)-py$(PYTHON_VERSION) || exit 1
	@if [ -n "$(VERSION)" ]; then \
		docker tag $(PYTHON_IMAGE):py$(PYTHON_VERSION) $(PYTHON_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$(PYTHON_VERSION) || exit 1; \
	fi

build-go:
	@echo "Building $(GO_IMAGE):latest"
	docker build --build-arg RALPHEX_GO_VERSION=$(RALPHEX_GO_VERSION) -t $(GO_IMAGE):latest docker-go/ || exit 1
	docker tag $(GO_IMAGE):latest $(GO_IMAGE):r$(RALPHEX_GO_VERSION) || exit 1
	@if [ -n "$(VERSION)" ]; then \
		docker tag $(GO_IMAGE):latest $(GO_IMAGE):$(VERSION)-r$(RALPHEX_GO_VERSION) || exit 1; \
	fi

push: push-python push-go

push-python:
	@for ver in $(PYTHON_VERSIONS); do \
		echo "Pushing $(PYTHON_IMAGE):py$$ver"; \
		docker push $(PYTHON_IMAGE):py$$ver || exit 1; \
		echo "Pushing $(PYTHON_IMAGE):r$(RALPHEX_VERSION)-py$$ver"; \
		docker push $(PYTHON_IMAGE):r$(RALPHEX_VERSION)-py$$ver || exit 1; \
		if [ -n "$(VERSION)" ]; then \
			echo "Pushing $(PYTHON_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$$ver"; \
			docker push $(PYTHON_IMAGE):$(VERSION)-r$(RALPHEX_VERSION)-py$$ver || exit 1; \
		fi; \
	done

push-go:
	@echo "Pushing $(GO_IMAGE):latest"
	docker push $(GO_IMAGE):latest || exit 1
	@echo "Pushing $(GO_IMAGE):r$(RALPHEX_GO_VERSION)"
	docker push $(GO_IMAGE):r$(RALPHEX_GO_VERSION) || exit 1
	@if [ -n "$(VERSION)" ]; then \
		echo "Pushing $(GO_IMAGE):$(VERSION)-r$(RALPHEX_GO_VERSION)"; \
		docker push $(GO_IMAGE):$(VERSION)-r$(RALPHEX_GO_VERSION) || exit 1; \
	fi
