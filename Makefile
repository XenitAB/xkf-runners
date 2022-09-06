.ONESHELL:
SHELL:=/bin/bash

IMAGE="ghcr.io/xenitab/github-actions/tools:2022.08.4"
TEMP_ENV_FILE:=$(shell mktemp)

VERSION=1.0.0

AZURE_CONFIG_DIR := $(if $(AZURE_CONFIG_DIR),$(AZURE_CONFIG_DIR),"$${HOME}/.azure")
TTY_OPTIONS=$(shell [ -t 0 ] && echo '-it')
TEMP_ENV_FILE:=$(shell mktemp)

DOCKER_RUN:=docker run  $(TTY_OPTIONS) --env-file $(TEMP_ENV_FILE) -v $(AZURE_CONFIG_DIR):/work/.azure -v $${PWD}:/tmp $(IMAGE) packer build 

.PHONY: setup
.SILENT: setup
setup:
	set -e

	mkdir -p $(AZURE_CONFIG_DIR)
	export AZURE_CONFIG_DIR="$(AZURE_CONFIG_DIR)"

	echo PKR_VAR_version=$(VERSION) >> $(TEMP_ENV_FILE)
	env | grep PKR_VAR_ >> $(TEMP_ENV_FILE)

	if [ -z "$${PKR_VAR_subscription_id}" ]; then
		echo PKR_VAR_subscription_id=$$(az account show -o tsv --query 'id') >> $(TEMP_ENV_FILE)
	fi


.PHONY: teardown
.SILENT: teardown
teardown:
	-rm -f $(TEMP_ENV_FILE)

.PHONY: azdo-agent
azdo-agent: setup
	echo PKR_VAR_image_name=azdo-agent >> $(TEMP_ENV_FILE)
	$(DOCKER_RUN) /tmp/packer/azure/template.pkr.hcl

.PHONY: github-runner
github-runner: setup
	echo PKR_VAR_image_name=github-runner >> $(TEMP_ENV_FILE)
	$(DOCKER_RUN) /tmp/packer/azure/template.pkr.hcl
	
.PHONY: all
all: azdo-agent github-runner
	
