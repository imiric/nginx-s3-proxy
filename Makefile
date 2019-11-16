# http://clarkgrubb.com/makefile-style-guide
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:


NAME        ?= nginx-s3-proxy
IMAGE       := nginx-s3-proxy
IMAGE_LE    := $(IMAGE)-letsencrypt
VERSION     ?= latest
RUNARGS     := -d --name $(NAME)
RUNARGS_TLS := -v /etc/letsencrypt:/etc/letsencrypt:ro \
               -v /etc/ssl/dhparam.pem:/etc/ssl/dhparam.pem:ro

ifdef DEBUG
	RUNARGS := -it --rm --name $(NAME)
endif

ifdef LETSENCRYPT
	IMAGE := $(IMAGE_LE)
	RUNARGS_TLS := $(subst letsencrypt:ro,letsencrypt:rw,$(RUNARGS_TLS))
	RUNARGS := $(RUNARGS) -e LETSENCRYPT=1
endif

ifeq ($(ENV), prod)
	RUNARGS := $(RUNARGS) $(RUNARGS_TLS) -e ENV=prod \
		-p '0.0.0.0:80:80' -p '0.0.0.0:443:443' --network=host
else
	RUNARGS := $(RUNARGS) -p '127.0.0.1:8000:80'
endif

.PHONY: image
image:
	podman build --target prod -t imiric/$(IMAGE):$(VERSION) .

.PHONY: image-letsencrypt
image-letsencrypt:
	test $(LETSENCRYPT)
	podman build --target letsencrypt -t imiric/$(IMAGE):$(VERSION) .

.PHONY: run
run:
	podman run $(RUNARGS) \
		-v $(CURDIR)/secrets.env:/run/secrets/secrets.env \
		imiric/$(IMAGE):$(VERSION)
