# http://clarkgrubb.com/makefile-style-guide
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:


NAME    ?= nginx-s3-proxy
VERSION ?= latest

ifeq ($(ENV), prod)
	RUNARGS := -p '0.0.0.0:80:80' -p '0.0.0.0:443:443' \
		-v /etc/letsencrypt:/etc/letsencrypt:ro \
		-v /etc/ssl/dhparam.pem:/etc/ssl/dhparam.pem:ro \
		--network=host
else
	RUNARGS := -p '127.0.0.1:8000:80'
endif


.PHONY: image
image:
	podman build -t imiric/nginx-s3-proxy:$(VERSION) .

.PHONY: run
run:
	podman run --rm -it --name $(NAME) \
		-v $(CURDIR)/secrets.env:/run/secrets/secrets.env \
		$(RUNARGS) imiric/nginx-s3-proxy:$(VERSION)
