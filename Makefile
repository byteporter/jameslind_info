SHELL := /bin/sh

# Terminal color control strings
RED=\e[1;31m
GRN=\e[1;32m
YEL=\e[1;33m
BLU=\e[1;34m
MAG=\e[1;35m
CYN=\e[1;36m
END=\e[0m

CONTENT := $(shell find resume/web -type f)

.PHONY: all clean install uninstall

all: .application-container

clean:
	@printf '$(BLU)Cleaning up...$(END)\n'
	docker image rm jlind/resume ||:
	rm .application-container ||:
	@printf '$(GRN)Done!$(END)\n\n'

.application-container: resume/cmd/resume/resume.go $(CONTENT) Dockerfile .go-build-environment .pandoc-build-environment
	@printf '$(BLU)Building $(YEL)Docker$(BLU) container $(CYN)jlind/resume$(BLU)...$(END)\n'
	docker build -t jlind/resume .
	touch .application-container
	@printf '$(GRN)Done!$(END)\n\n'

.go-build-environment: resume/build/package/docker/go-build-environment/
	@printf '$(BLU)Building $(YEL)Docker$(BLU) container $(CYN)jlind/go-build-environment$(BLU)...$(END)\n'
	cd $< && docker build -t jlind/go-build-environment .
	touch .go-build-environment
	@printf '$(GRN)Done!$(END)\n\n'

.pandoc-build-environment: resume/build/package/docker/pandoc-build-environment/
	@printf '$(BLU)Building $(YEL)Docker$(BLU) container $(CYN)jlind/pandoc-build-environment$(BLU)...$(END)\n'
	cd $< && docker build -t jlind/pandoc-build-environment .
	touch .pandoc-build-environment
	@printf '$(GRN)Done!$(END)\n\n'
