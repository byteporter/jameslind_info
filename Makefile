SHELL := /bin/sh

# TODO: Move dependencies into resume/vendor folder for use in building within the Docker build environment containers

# Terminal color control strings
RED=\e[1;31m
GRN=\e[1;32m
YEL=\e[1;33m
BLU=\e[1;34m
MAG=\e[1;35m
CYN=\e[1;36m
END=\e[0m

CONTENT := $(shell find resume/web -type f)
STYLES := $(shell find resume/tools/style-templates -type f)
FULL_PATH := $(realpath resume/)

UNIT_PATH := /etc/systemd/system
SERVICE_PATH := /opt/resume
SERVICE_FILES := Dockerfile docker-compose.yml docker-compose.override.yml.dist .env.dist
SERVER_URL := jameslind.info

.PHONY: all clean install uninstall

all: .application-container

clean:
	@printf '$(BLU)Cleaning up...$(END)\n'
	docker image rm jlind/resume ||:
	docker rm holder ||:
	docker volume rm resume-build-volume ||:
	rm .application-container ||:
	@printf '$(GRN)Done!$(END)\n\n'

# Jenkins will be used to build this and runs in a container itself so is unable to bind mount a directory from its filesystem.
# This is the workaround I came up with, build in a volume, archive the results, and ADD that archive in the Dockerfile build.

.application-container: resume/cmd/resume/resume.go $(CONTENT) $(STYLES) Dockerfile .patch-russross-blackfriday .go-build-environment .pandoc-build-environment .node-build-environment
	@printf '$(BLU)Building $(YEL)Docker$(BLU) container $(CYN)jlind/resume$(BLU)...$(END)\n'
	docker run -d --rm --name holder -v resume-build-volume:/build busybox sleep 600
	docker cp $(FULL_PATH)/. holder:/build
	docker run --rm -v resume-build-volume:/go/src/github.com/byteporter/resume/ -w /go/src/github.com/byteporter/resume/ jlind/go-build-environment make resume
	docker run --rm -v resume-build-volume:/go/src/github.com/byteporter/resume/ -w /go/src/github.com/byteporter/resume/ jlind/pandoc-build-environment make hardcopy
	docker run --rm -v resume-build-volume:/go/src/github.com/byteporter/resume/ -w /go/src/github.com/byteporter/resume/ jlind/node-build-environment make install
	docker run --rm -v resume-build-volume:/build busybox chown -R $$(id -u):$$(id -g) /build/output/
	docker run --rm -v resume-build-volume:/build busybox tar cfvz /build/resume-build-output.tar.gz -C /build/output/ .
	docker cp holder:/build/resume-build-output.tar.gz $(realpath ./)
	docker rm -f holder
	docker build -t jlind/resume .
	touch $@
	@printf '$(GRN)Done!$(END)\n\n'

.go-build-environment: resume/build/package/docker/go-build-environment/Dockerfile
	@printf '$(BLU)Building $(YEL)Docker$(BLU) container $(CYN)jlind/go-build-environment$(BLU)...$(END)\n'
	cd $(dir $<) && docker build -t jlind/go-build-environment .
	touch $@
	@printf '$(GRN)Done!$(END)\n\n'

.pandoc-build-environment: resume/build/package/docker/pandoc-build-environment/Dockerfile
	@printf '$(BLU)Building $(YEL)Docker$(BLU) container $(CYN)jlind/pandoc-build-environment$(BLU)...$(END)\n'
	cd $(dir $<) && docker build -t jlind/pandoc-build-environment .
	touch $@
	@printf '$(GRN)Done!$(END)\n\n'

.node-build-environment: resume/build/package/docker/node-build-environment/Dockerfile
	@printf '$(BLU)Building $(YEL)Docker$(BLU) container $(CYN)jlind/node-build-environment$(BLU)...$(END)\n'
	cd $(dir $<) && docker build -t jlind/node-build-environment .
	touch $@
	@printf '$(GRN)Done!$(END)\n\n'

BLACKFRIDAY_PATH := $(realpath resume/vendor/github.com/russross/blackfriday/)
BLACKFRIDAY_PATCH_PATH := $(realpath resume/vendor/patches/github.com/russross/blackfriday/)

.patch-russross-blackfriday: $(BLACKFRIDAY_PATCH_PATH)/html.go.fix-align-tags.patch $(BLACKFRIDAY_PATH)/html.go
	@printf '$(BLU)Patching blackfriday submodule...$(END)\n'
	cd $(BLACKFRIDAY_PATH) && git apply $<
	touch $@
	@printf '$(GRN)Done!$(END)\n\n'

install:
	@printf '$(BLU)Installing onto $(SERVER_URL)...$(END)\n'
	rsync -vzh --rsync-path='sudo rsync' docker.resume.service core@$(SERVER_URL):$(UNIT_PATH)/
	rsync -vzh $(SERVICE_FILES) core@$(SERVER_URL):$(SERVICE_PATH)/
	@printf '$(GRN)Done!$(END)\n\n'
