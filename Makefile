# =========================
# Rescatux Build System
# =========================

include distro.conf
export

PLATFORMS := amd64-iso amd64-usb i386-iso i386-usb
ARCHS := amd64 i386

ROOT := $(shell pwd)

BUILDX_BUILDER := rescatux-buildx-builder

# =========================
# Stage 0 — Bootstrap
# =========================

.PHONY: bootstrap

bootstrap:
	@echo ">> Checking buildx builder..."
	@if ! docker buildx inspect $(BUILDX_BUILDER) >/dev/null 2>&1; then \
		echo ">> Creating buildx builder..."; \
		docker buildx create --name $(BUILDX_BUILDER); \
	fi

	@echo ">> Using buildx builder..."
	@docker buildx use $(BUILDX_BUILDER)

	@echo ">> Bootstrapping builder..."
	@docker buildx inspect --bootstrap >/dev/null

	@echo ">> Checking binfmt (QEMU)..."
	@if ! docker run --rm --platform=linux/386 debian:bookworm true >/dev/null 2>&1; then \
		echo ">> Installing binfmt emulation..."; \
		docker run --privileged --rm tonistiigi/binfmt --install all; \
	else \
		echo ">> binfmt already working"; \
	fi

# =========================
# Stage 1 — Dependencies
# =========================

.PHONY: deps

deps:
	scripts/build-live-build.sh
	scripts/build-live-boot.sh

# =========================
# Stage 2 — Builder Images
# =========================

.PHONY: builder builder-amd64 builder-i386

builder: bootstrap builder-amd64 builder-i386

builder-amd64:
	docker buildx build \
		--load \
		--platform linux/amd64 \
		-t rescatux-builder-amd64 \
		-f builder/Dockerfile.amd64 \
		.

builder-i386:
	docker buildx build \
		--load \
		--platform linux/386 \
		-t rescatux-builder-i386 \
		-f builder/Dockerfile.i386 \
		.

# =========================
# Stage 3 — Config
# =========================

# Helper to require variables
define require_var
  ifndef $(1)
    $$(error $(1) is not set. Usage: make $(MAKECMDGOALS) $(1)=<value> (e.g. $(1)=amd64-iso))
  endif
  ifeq ($$(strip $$($(1))),)
    $$(error $(1) is empty. Usage: make $(MAKECMDGOALS) $(1)=<value> (e.g. $(1)=amd64-iso))
  endif
endef

# Apply only to targets that need PLATFORM
ifneq (,$(filter prepare build shell,$(MAKECMDGOALS)))
$(eval $(call require_var,PLATFORM))
endif

.PHONY: prepare

prepare:
	scripts/prepare-config.sh $(PLATFORM)

# =========================
# Stage 4 — Build (live-build)
# =========================

.PHONY: build

build:
	scripts/run-live-build.sh $(PLATFORM)

# =========================
# Stage 5 — Package
# =========================

.PHONY: package

package:
	scripts/package-artifacts.sh

# =========================
# Stage 6 — Release
# =========================

.PHONY: release

release: deps builder build-all package

# =========================
# Build All Platforms
# =========================

.PHONY: build-all

build-all:
	@for p in $(PLATFORMS); do \
		echo ">> Building $$p"; \
		$(MAKE) prepare PLATFORM=$$p; \
		$(MAKE) build PLATFORM=$$p; \
	done

# =========================
# Developer Shell
# =========================

.PHONY: shell shell-amd64 shell-i386

shell:
	scripts/dev-shell.sh $(PLATFORM)

shell-amd64:
	docker run --rm -it \
		-v $(ROOT):/workspace \
		rescatux-builder-amd64 bash

shell-i386:
	docker run --rm -it \
		-v $(ROOT):/workspace \
		rescatux-builder-i386 bash

# =========================
# Debug / Validation
# =========================

.PHONY: check check-amd64 check-i386

check: check-amd64 check-i386

check-amd64:
	docker run --rm rescatux-builder-amd64 dpkg -l | grep live-

check-i386:
	docker run --rm rescatux-builder-i386 dpkg -l | grep live-

# =========================
# Clean
# =========================

.PHONY: clean

clean: builder-amd64
	@echo ">> Cleaning build artifacts (via Docker)"
	docker run --rm \
		-v $(ROOT):/workspace \
		rescatux-builder-amd64 \
		bash -c "rm -rf /workspace/build/work/* /workspace/dist/*"
