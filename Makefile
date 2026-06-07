# =========================
# Rescatux Build System
# =========================

include distro.conf
-include config.mk
export

PLATFORMS := amd64-iso amd64-usb i386-iso i386-usb
ARCHS := amd64 i386
CLEAN_PLATFORMS := $(if $(strip $(PLATFORM)),$(PLATFORM),$(PLATFORMS))

ROOT := $(shell pwd)

BUILDX_BUILDER := rescatux-buildx-builder

# =========================
# Run Configuration
# =========================

RUN_SOURCE ?= dev
RUN_DISPLAY ?=
RUN_MEMORY ?= 2048
RUN_CPUS ?= 2
RUN_KVM ?= -enable-kvm -cpu host
ISO ?=
IMG ?=

# =========================
# OVMF Auto-Detection
# =========================

OVMF_PATHS := \
	/usr/share/OVMF/ \
	/usr/share/edk2/ovmf/ \
	/usr/share/edk2/x64/ \
	/usr/share/edk2/ia32/

define find_ovmf
$(firstword $(wildcard $(foreach path,$(1),$(path)$(2))))
endef

ifndef OVMF_CODE_FD
OVMF_CODE_FD := $(call find_ovmf,$(OVMF_PATHS),OVMF_CODE.fd)
endif
ifndef OVMF_CODE_SECB_FD
OVMF_CODE_SECB_FD := $(call find_ovmf,$(OVMF_PATHS),OVMF_CODE.secboot.fd)
endif
ifndef OVMF_VARS_FD
OVMF_VARS_FD := $(call find_ovmf,$(OVMF_PATHS),OVMF_VARS.fd)
endif
ifndef OVMF32_CODE_FD
OVMF32_CODE_FD := $(call find_ovmf,$(OVMF_PATHS),OVMF32_CODE_4M.fd)
endif
ifndef OVMF32_CODE_SECB_FD
OVMF32_CODE_SECB_FD := $(call find_ovmf,$(OVMF_PATHS),OVMF32_CODE_4M.secboot.fd)
endif
ifndef OVMF32_VARS_FD
OVMF32_VARS_FD := $(call find_ovmf,$(OVMF_PATHS),OVMF32_VARS.fd)
endif

# =========================
# Artifact Path Resolution
# =========================

# dev source paths
dev_iso_amd64 := build/work/amd64-iso/live-image-amd64.iso
dev_iso_i386 := build/work/i386-iso/live-image-i386.iso
dev_img_amd64 := build/work/amd64-usb/live-image-amd64.img
dev_img_i386 := build/work/i386-usb/live-image-i386.img

# dist source paths
dist_iso_amd64 := dist/rescatux-$(VERSION)-amd64.iso
dist_iso_i386 := dist/rescatux-$(VERSION)-i386.iso
dist_img_amd64 := dist/rescatux-$(VERSION)-amd64-usb.img
dist_img_i386 := dist/rescatux-$(VERSION)-i386-usb.img

ifeq ($(RUN_SOURCE),dev)
iso_amd64 := $(dev_iso_amd64)
iso_i386 := $(dev_iso_i386)
img_amd64 := $(dev_img_amd64)
img_i386 := $(dev_img_i386)
else
iso_amd64 := $(dist_iso_amd64)
iso_i386 := $(dist_iso_i386)
img_amd64 := $(dist_img_amd64)
img_i386 := $(dist_img_i386)
endif

# Allow ISO/IMG overrides
ifeq ($(ISO),)
RUN_ISO_amd64 := $(iso_amd64)
RUN_ISO_i386 := $(iso_i386)
else
RUN_ISO_amd64 := $(ISO)
RUN_ISO_i386 := $(ISO)
endif

ifeq ($(IMG),)
RUN_IMG_amd64 := $(img_amd64)
RUN_IMG_i386 := $(img_i386)
else
RUN_IMG_amd64 := $(IMG)
RUN_IMG_i386 := $(IMG)
endif

# =========================
# Run Vars Directory
# =========================

RUN_VARS_DIR := $(ROOT)/make-run-vars

define copy_vars_fd
mkdir -p $(RUN_VARS_DIR); \
cp $(1) $(RUN_VARS_DIR)/$(2) && \
echo $(RUN_VARS_DIR)/$(2)
endef

# =========================
# QEMU Command Macros
# =========================

define qemu_base
qemu-system-$(1) \
	$(RUN_KVM) \
	-m $(RUN_MEMORY) \
	-smp $(RUN_CPUS) \
	-vga virtio \
	$(RUN_DISPLAY)
endef

define qemu_uefi_amd64
$(call qemu_base,x86_64) \
	-machine q35,smm=on \
	-drive if=pflash,format=raw,readonly=on,file=$(OVMF_CODE_FD) \
	-drive if=pflash,format=raw,file=$(1)
endef

define qemu_uefi_sb_amd64
$(call qemu_base,x86_64) \
	-machine q35,smm=on \
	-global driver=cfi.pflash01,property=secure,value=on \
	-drive if=pflash,format=raw,readonly=on,file=$(OVMF_CODE_SECB_FD) \
	-drive if=pflash,format=raw,file=$(1)
endef

define qemu_uefi_i386
$(call qemu_base,i386) \
	-machine q35,smm=on \
	-drive if=pflash,format=raw,readonly=on,file=$(OVMF32_CODE_FD) \
	-drive if=pflash,format=raw,file=$(1)
endef

define qemu_uefi_sb_i386
$(call qemu_base,i386) \
	-machine q35,smm=on \
	-global driver=cfi.pflash01,property=secure,value=on \
	-drive if=pflash,format=raw,readonly=on,file=$(OVMF32_CODE_SECB_FD) \
	-drive if=pflash,format=raw,file=$(1)
endef

define qemu_bios_amd64
$(call qemu_base,x86_64)
endef

define qemu_bios_i386
$(call qemu_base,i386)
endef

# =========================
# Firmware Validation
# =========================

define check_ovmf
@if [ -z "$(1)" ]; then \
	echo "ERROR: Missing OVMF firmware: $(2)"; \
	echo "Install ovmf (or ovmf-ia32 for 32-bit) or set path in config.mk"; \
	exit 1; \
fi
endef

PLATFORM_amd64 := linux/amd64
PLATFORM_i386  := linux/386

define BUILDER_template

builder-$(1): .builder-$(1).stamp

.builder-$(1).stamp: builder/Dockerfile.$(1)
	@echo ">> Checking $(1) builder image..."
	@HASH=$$(sha256sum builder/Dockerfile.$(1) | cut -d' ' -f1); \
	if [ ! -f $$@ ] || ! grep -q $$HASH $$@ || ! docker image inspect rescatux-builder-$(1) >/dev/null 2>&1; then \
		echo ">> Rebuilding $(1) image (missing or changed)"; \
		docker buildx build \
			--load \
			--platform $(PLATFORM_$(1)) \
			-t rescatux-builder-$(1) \
			-f builder/Dockerfile.$(1) \
			.; \
		echo $$HASH > $$@; \
	else \
		echo ">> $(1) image up-to-date"; \
	fi

endef

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

# builder-amd64
$(eval $(call BUILDER_template,amd64))

# builder-i386
$(eval $(call BUILDER_template,i386))

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

# Prepares build workspace without deleting cached data
prepare:
	scripts/run-prepare-config.sh $(PLATFORM)

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
	@for p in $(if $(strip $(PLATFORM)),$(PLATFORM),$(PLATFORMS)); do \
		echo ">> Packaging $$p"; \
		scripts/package-artifacts.sh $$p; \
	done

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
		bash -ec '\
			set -eu; \
			for p in $(CLEAN_PLATFORMS); do \
				case "$$p" in \
					amd64-iso) \
						rm -rf "/workspace/build/work/$$p"; \
						rm -f "/workspace/dist/rescatux-$(VERSION)-amd64.iso"; \
						;; \
					amd64-usb) \
						rm -rf "/workspace/build/work/$$p"; \
						rm -f "/workspace/dist/rescatux-$(VERSION)-amd64-usb.img" "/workspace/dist/rescatux-$(VERSION)-amd64-usb.img.zip"; \
						;; \
					i386-iso) \
						rm -rf "/workspace/build/work/$$p"; \
						rm -f "/workspace/dist/rescatux-$(VERSION)-i386.iso"; \
						;; \
					i386-usb) \
						rm -rf "/workspace/build/work/$$p"; \
						rm -f "/workspace/dist/rescatux-$(VERSION)-i386-usb.img" "/workspace/dist/rescatux-$(VERSION)-i386-usb.img.zip"; \
						;; \
				esac; \
			done'

# =========================
# Run Targets — QEMU/KVM Testing
# =========================

.PHONY: run-help run run-amd64 run-amd64-uefi run-amd64-uefi-sb-iso run-amd64-uefi-sb-usb run-amd64-uefi-iso run-amd64-uefi-usb run-amd64-bios-iso run-amd64-bios-usb run-i386 run-i386-uefi run-i386-uefi-sb-iso run-i386-uefi-sb-usb run-i386-uefi-iso run-i386-uefi-usb run-i386-bios-iso run-i386-bios-usb

# Help target
run-help:
	@echo "Rescatux QEMU/KVM Run Targets"
	@echo ""
	@echo "Individual targets (12):"
	@echo "  run-amd64-uefi-sb-iso   run-amd64-uefi-sb-usb"
	@echo "  run-amd64-uefi-iso      run-amd64-uefi-usb"
	@echo "  run-amd64-bios-iso      run-amd64-bios-usb"
	@echo "  run-i386-uefi-sb-iso    run-i386-uefi-sb-usb"
	@echo "  run-i386-uefi-iso       run-i386-uefi-usb"
	@echo "  run-i386-bios-iso       run-i386-bios-usb"
	@echo ""
	@echo "Hierarchical defaults (4):"
	@echo "  run-amd64-uefi  → Defaults: SecureBoot=enabled, Media=ISO"
	@echo "  run-amd64       → Defaults: Boot=UEFI, SecureBoot=enabled, Media=ISO"
	@echo "  run-i386        → Defaults: Boot=UEFI, SecureBoot=enabled, Media=ISO"
	@echo "  run             → Defaults: Arch=AMD64, Boot=UEFI, SecureBoot=enabled, Media=ISO"
	@echo ""
	@echo "Key variables:"
	@echo "  RUN_SOURCE=dev|dist   (default: dev) — dev=build/work, dist=packaged artifacts"
	@echo "  RUN_DISPLAY=          (default: graphical) — e.g. '-nographic -serial stdio' for CI"
	@echo "  RUN_MEMORY=2048       (MB)"
	@echo "  RUN_CPUS=2            (vCPUs)"
	@echo "  RUN_KVM='-enable-kvm -cpu host'"
	@echo "  ISO=/path/to.iso      Override ISO path"
	@echo "  IMG=/path/to.img      Override IMG path"
	@echo "  OVMF_CODE_FD etc.     Override in config.mk"

# Hierarchical defaults (show defaulting messages)
run: run-amd64-uefi-sb-iso
	@echo ">> Defaulting: run → amd64, UEFI, SecureBoot, ISO"

run-amd64: run-amd64-uefi
	@echo ">> Defaulting: run-amd64 → UEFI, SecureBoot, ISO"

run-amd64-uefi: run-amd64-uefi-sb-iso
	@echo ">> Defaulting: run-amd64-uefi → SecureBoot, ISO"

run-i386: run-i386-uefi
	@echo ">> Defaulting: run-i386 → UEFI, SecureBoot, ISO"

run-i386-uefi: run-i386-uefi-sb-iso
	@echo ">> Defaulting: run-i386-uefi → SecureBoot, ISO"

# AMD64 UEFI SecureBoot
run-amd64-uefi-sb-iso:
	$(call check_ovmf,$(OVMF_CODE_SECB_FD),OVMF_CODE.secboot.fd)
	$(call check_ovmf,$(OVMF_VARS_FD),OVMF_VARS.fd)
	$(eval RUN_VARS_FD := $(shell $(call copy_vars_fd,$(OVMF_VARS_FD),rescatux-amd64-uefi-sb-iso_VARS.fd)))
	$(call qemu_uefi_sb_amd64,$(RUN_VARS_FD)) -drive file=$(RUN_ISO_amd64),format=raw,if=virtio,readonly=on,media=cdrom

run-amd64-uefi-sb-usb:
	$(call check_ovmf,$(OVMF_CODE_SECB_FD),OVMF_CODE.secboot.fd)
	$(call check_ovmf,$(OVMF_VARS_FD),OVMF_VARS.fd)
	$(eval RUN_VARS_FD := $(shell $(call copy_vars_fd,$(OVMF_VARS_FD),rescatux-amd64-uefi-sb-usb_VARS.fd)))
	$(call qemu_uefi_sb_amd64,$(RUN_VARS_FD)) -drive file=$(RUN_IMG_amd64),format=raw,if=virtio,readonly=on

# AMD64 UEFI (no SecureBoot)
run-amd64-uefi-iso:
	$(call check_ovmf,$(OVMF_CODE_FD),OVMF_CODE.fd)
	$(call check_ovmf,$(OVMF_VARS_FD),OVMF_VARS.fd)
	$(eval RUN_VARS_FD := $(shell $(call copy_vars_fd,$(OVMF_VARS_FD),rescatux-amd64-uefi-iso_VARS.fd)))
	$(call qemu_uefi_amd64,$(RUN_VARS_FD)) -drive file=$(RUN_ISO_amd64),format=raw,if=virtio,readonly=on,media=cdrom

run-amd64-uefi-usb:
	$(call check_ovmf,$(OVMF_CODE_FD),OVMF_CODE.fd)
	$(call check_ovmf,$(OVMF_VARS_FD),OVMF_VARS.fd)
	$(eval RUN_VARS_FD := $(shell $(call copy_vars_fd,$(OVMF_VARS_FD),rescatux-amd64-uefi-usb_VARS.fd)))
	$(call qemu_uefi_amd64,$(RUN_VARS_FD)) -drive file=$(RUN_IMG_amd64),format=raw,if=virtio,readonly=on

# AMD64 BIOS
run-amd64-bios-iso:
	$(call qemu_bios_amd64) -drive file=$(RUN_ISO_amd64),format=raw,if=virtio,readonly=on,media=cdrom

run-amd64-bios-usb:
	$(call qemu_bios_amd64) -drive file=$(RUN_IMG_amd64),format=raw,if=virtio,readonly=on

# I386 UEFI SecureBoot
run-i386-uefi-sb-iso:
	$(call check_ovmf,$(OVMF32_CODE_SECB_FD),OVMF32_CODE_4M.secboot.fd)
	$(call check_ovmf,$(OVMF32_VARS_FD),OVMF32_VARS.fd)
	$(eval RUN_VARS_FD := $(shell $(call copy_vars_fd,$(OVMF32_VARS_FD),rescatux-i386-uefi-sb-iso_VARS.fd)))
	$(call qemu_uefi_sb_i386,$(RUN_VARS_FD)) -drive file=$(RUN_ISO_i386),format=raw,if=virtio,readonly=on,media=cdrom

run-i386-uefi-sb-usb:
	$(call check_ovmf,$(OVMF32_CODE_SECB_FD),OVMF32_CODE_4M.secboot.fd)
	$(call check_ovmf,$(OVMF32_VARS_FD),OVMF32_VARS.fd)
	$(eval RUN_VARS_FD := $(shell $(call copy_vars_fd,$(OVMF32_VARS_FD),rescatux-i386-uefi-sb-usb_VARS.fd)))
	$(call qemu_uefi_sb_i386,$(RUN_VARS_FD)) -drive file=$(RUN_IMG_i386),format=raw,if=virtio,readonly=on

# I386 UEFI (no SecureBoot)
run-i386-uefi-iso:
	$(call check_ovmf,$(OVMF32_CODE_FD),OVMF32_CODE_4M.fd)
	$(call check_ovmf,$(OVMF32_VARS_FD),OVMF32_VARS.fd)
	$(eval RUN_VARS_FD := $(shell $(call copy_vars_fd,$(OVMF32_VARS_FD),rescatux-i386-uefi-iso_VARS.fd)))
	$(call qemu_uefi_i386,$(RUN_VARS_FD)) -drive file=$(RUN_ISO_i386),format=raw,if=virtio,readonly=on,media=cdrom

run-i386-uefi-usb:
	$(call check_ovmf,$(OVMF32_CODE_FD),OVMF32_CODE_4M.fd)
	$(call check_ovmf,$(OVMF32_VARS_FD),OVMF32_VARS.fd)
	$(eval RUN_VARS_FD := $(shell $(call copy_vars_fd,$(OVMF32_VARS_FD),rescatux-i386-uefi-usb_VARS.fd)))
	$(call qemu_uefi_i386,$(RUN_VARS_FD)) -drive file=$(RUN_IMG_i386),format=raw,if=virtio,readonly=on

# I386 BIOS
run-i386-bios-iso:
	$(call qemu_bios_i386) -drive file=$(RUN_ISO_i386),format=raw,if=virtio,readonly=on,media=cdrom

run-i386-bios-usb:
	$(call qemu_bios_i386) -drive file=$(RUN_IMG_i386),format=raw,if=virtio,readonly=on
