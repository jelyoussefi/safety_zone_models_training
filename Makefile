#----------------------------------------------------------------------------------------------------------------------
# Flags
#----------------------------------------------------------------------------------------------------------------------
SHELL:=/bin/bash
CURRENT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

MODEL_SIZE ?= s
IMAGE_SIZE ?= 640
BATCH_SIZE ?= 1024
EPOCHS ?= 30


MODEL_NAME = yolo11${MODEL_SIZE}

DEVICE ?= CPU

#----------------------------------------------------------------------------------------------------------------------
# Docker Settings
#----------------------------------------------------------------------------------------------------------------------
DOCKER_IMAGE_NAME=safety_zone_model_training
export DOCKER_BUILDKIT=1

DOCKER_RUN_PARAMS= \
	-it --rm -a stdout -a stderr  \
	-v ${CURRENT_DIR}:/workspace \
	-e HTTP_PROXY=$(HTTP_PROXY) \
	-e HTTPS_PROXY=$(HTTPS_PROXY) \
	-e NO_PROXY=$(NO_PROXY) \
	${DOCKER_IMAGE_NAME}

DOCKER_BUILD_PARAMS := \
	--rm \
	--network=host \
	--build-arg http_proxy=$(HTTP_PROXY) \
	--build-arg https_proxy=$(HTTPS_PROXY) \
	--build-arg no_proxy=$(NO_PROXY) \
	-t $(DOCKER_IMAGE_NAME) . 
	
#----------------------------------------------------------------------------------------------------------------------
# Targets
#----------------------------------------------------------------------------------------------------------------------
default: all
.PHONY: build train_helmet train_qr_code

all: train_helmet train_qr_code

build:
	@$(call msg, Building Docker image ${DOCKER_IMAGE_NAME} ...)
	@docker build ${DOCKER_BUILD_PARAMS}

train_helmet: build
	@$(call msg, Training the ${MODEL_NAME} model for helmet detection ...)
	@sudo rm -rf ./runs/detect/${MODEL_NAME}*
	@docker run ${DOCKER_RUN_PARAMS} \
		yolo detect train \
			model=${MODEL_NAME}.pt \
			name=${MODEL_NAME} \
			data=./dataset/helmet/data.yaml \
			imgsz=${IMAGE_SIZE} \
			epochs=${EPOCHS} \
			batch=${BATCH_SIZE} \
			device=${DEVICE}

train_qr_code: build
	@$(call msg, Training the ${MODEL_NAME} model for qr_code detection ...)
	@sudo rm -rf ./runs/detect/${MODEL_NAME}*
	@docker run ${DOCKER_RUN_PARAMS} \
		yolo detect train \
			model=${MODEL_NAME}.pt \
			name=${MODEL_NAME} \
			data=./dataset/qr_code/data.yaml \
			imgsz=${IMAGE_SIZE} \
			epochs=${EPOCHS} \
			batch=${BATCH_SIZE} \
			device=${DEVICE}
			

#----------------------------------------------------------------------------------------------------------------------
# Helper functions
#----------------------------------------------------------------------------------------------------------------------
define msg
	tput setaf 2 && \
	for i in $(shell seq 1 120 ); do echo -n "-"; done; echo  "" && \
	echo "         "$1 && \
	for i in $(shell seq 1 120 ); do echo -n "-"; done; echo "" && \
	tput sgr0
endef
