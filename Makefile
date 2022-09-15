.ONESHELL:
SHELL:=/bin/bash

IMAGE="ghcr.io/xenitab/github-actions/tools:2022.08.4"
TEMP_ENV_FILE:=$(shell mktemp)

AZURE_CONFIG_DIR := $(if $(AZURE_CONFIG_DIR),$(AZURE_CONFIG_DIR),"$${HOME}/.azure")
TTY_OPTIONS=$(shell [ -t 0 ] && echo '-it')
TEMP_ENV_FILE:=$(shell mktemp)

DOCKER_RUN:=docker run $(TTY_OPTIONS) --env-file $(TEMP_ENV_FILE) -v $(AZURE_CONFIG_DIR):/work/.azure -v $${PWD}:/tmp $(IMAGE) packer
CLEANUP_COMMAND:=$(MAKE) --no-print-directory teardown TEMP_ENV_FILE=$(TEMP_ENV_FILE)

.PHONY: check-env
.SILENT: check-env
check-env:
ifndef PKR_VAR_version
	$(error PKR_VAR_version is undefined)
endif

.PHONY: setup
.SILENT: setup
setup: check-env
	set -e

	mkdir -p $(AZURE_CONFIG_DIR)
	export AZURE_CONFIG_DIR="$(AZURE_CONFIG_DIR)"

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
	trap '$(CLEANUP_COMMAND)' EXIT
	echo PKR_VAR_image_name=azdo-agent >> $(TEMP_ENV_FILE)
	$(DOCKER_RUN) build /tmp/packer/azure/template.pkr.hcl

.PHONY: github-runner
github-runner: setup
	trap '$(CLEANUP_COMMAND)' EXIT
	echo PKR_VAR_image_name=github-runner >> $(TEMP_ENV_FILE)
	$(DOCKER_RUN) build /tmp/packer/azure/template.pkr.hcl
	
.PHONY: validate
validate:
	trap '$(CLEANUP_COMMAND)' EXIT
	echo PKR_VAR_version=1.0.0 >> $(TEMP_ENV_FILE)
	echo PKR_VAR_resource_group=rg-dev-we-images >> $(TEMP_ENV_FILE)
	echo PKR_VAR_gallery_name=xkf >> $(TEMP_ENV_FILE)
	echo PKR_VAR_image_name=azdo-agent >> $(TEMP_ENV_FILE)
	echo PKR_VAR_subscription_id=12345 >> $(TEMP_ENV_FILE)
	$(DOCKER_RUN) validate /tmp/packer/azure/template.pkr.hcl
