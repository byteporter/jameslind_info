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

.application-container: resume/cmd/resume/resume.go $(CONTENT) $(STYLES) Dockerfile .go-build-environment .pandoc-build-environment .node-build-environment
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
	touch .application-container
	@printf '$(GRN)Done!$(END)\n\n'

.go-build-environment: resume/build/package/docker/go-build-environment/Dockerfile
	@printf '$(BLU)Building $(YEL)Docker$(BLU) container $(CYN)jlind/go-build-environment$(BLU)...$(END)\n'
	cd $(dir $<) && docker build -t jlind/go-build-environment .
	touch .go-build-environment
	@printf '$(GRN)Done!$(END)\n\n'

.pandoc-build-environment: resume/build/package/docker/pandoc-build-environment/Dockerfile
	@printf '$(BLU)Building $(YEL)Docker$(BLU) container $(CYN)jlind/pandoc-build-environment$(BLU)...$(END)\n'
	cd $(dir $<) && docker build -t jlind/pandoc-build-environment .
	touch .pandoc-build-environment
	@printf '$(GRN)Done!$(END)\n\n'

.node-build-environment: resume/build/package/docker/node-build-environment/Dockerfile
	@printf '$(BLU)Building $(YEL)Docker$(BLU) container $(CYN)jlind/node-build-environment$(BLU)...$(END)\n'
	cd $(dir $<) && docker build -t jlind/node-build-environment .
	touch .node-build-environment
	@printf '$(GRN)Done!$(END)\n\n'
