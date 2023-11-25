SHELL := /usr/bin/env bash

DOCKER := docker
CARGO := cargo

# Makefile settings
ifndef V
MAKEFLAGS += --no-print-directory
endif

THIS_FILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
ROOT_DIR ?= $(abspath $(shell cd $(THIS_FILE_DIR) && pwd -P))

ARROW_STRING := ===========>

# Useful when replace string.
COMMA := ,
SPACE :=
SPACE +=

.DEFAULT_GOAL := help


### run: run rust project.
.PHONY: run
run:
	@echo "$(ARROW_STRING) Run Rust project...."
	@$(CARGO) run


### build: build rust project.
.PHONY: build
build:
	@echo "$(ARROW_STRING) Build Rust project...."
	@$(CARGO) build -q

### build: build rust project for release.
.PHONY: build-release
build-release:
	@echo "$(ARROW_STRING) Build Rust project...."
	@$(CARGO) build -r -q

### build-linux-gnu: build rust project for linux release.
.PHONY: build-release-linux-gnu
build-release-linux-gnu:
	@echo "$(ARROW_STRING) Build Rust project...."
	@cross build -q -r --target x86_64-unknown-linux-gnu
	@mv target/x86_64-unknown-linux-gnu/release/rust-playground-server deployment/

### run-compose: run compose file.
.PHONY: run-compose
run-compose:install-cross build-release-linux-gnu
	@echo "$(ARROW_STRING) Up docker-compose file...."
	@$(DOCKER) compose up -d


### install-cross: install cross-build.
.PHONY: install-cross
install-cross:
	@echo "$(ARROW_STRING) Install cross-rs...."
	$(eval install_cross_rs := $(shell [[ "$(shell which cross)" =~ '.cargo/bin/cross' ]] && echo 0))
	$(if $(install_cross_rs), @echo 'cross-rs is installed!', @cargo install cross --git https://github.com/cross-rs/cross)
	$(eval add_arch := $(shell test "$(shell rustup target list | grep 'x86_64-unknown-linux-gnu (installed)' )" == 'x86_64-unknown-linux-gnu (installed)' && echo 0))
	$(if $(add_arch), @echo 'arch x86_64-unknown-linux-gnu added!', @rustup target add x86_64-unknown-linux-gnu)

### clean: clean files..
.PHONY: clean
clean:
	@echo "$(ARROW_STRING) Clean files...."


### help: Show this help info.
.PHONY: help
help: Makefile
	@printf "\nUsage: make <TARGETS> <OPTIONS> ...\n\nTargets:\n"
	@sed -n 's/^###//p' $< | column -t -s ':' | sed -e 's/^/ /'
	@echo ""
	@echo "$$USAGE_OPTIONS"