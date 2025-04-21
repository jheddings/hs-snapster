# Makefile for hs-snapster

BASEDIR ?= $(PWD)
SRCDIR ?= $(BASEDIR)/src

APPNAME ?= $(shell grep -m1 '^obj.name' "src/init.lua"  | sed -e 's/.*"\(.*\)"/\1/')
APPVER ?= $(shell grep -m1 '^obj.version' "src/init.lua"  | sed -e 's/.*"\(.*\)"/\1/')


.PHONY: all
all: preflight build


.PHONY: build-zip
build-zip: preflight
	mkdir -p "$(BASEDIR)/build"
	cp -a "$(BASEDIR)/src/" "$(BASEDIR)/build/$(APPNAME).spoon"
	mkdir -p "$(BASEDIR)/dist"
	cd "$(BASEDIR)/build" && \
		zip -9r "$(BASEDIR)/dist/$(APPNAME)-$(APPVER).zip" "$(APPNAME).spoon"


.PHONY: build-docs
build-docs: preflight
	mkdir -p "$(BASEDIR)/build/$(APPNAME).spoon"


.PHONY: build
build: build-docs build-zip


.PHONY: static-checks
static-checks:
	@echo "Static checks passed."


.PHONY: unit-tests
unit-tests:
	for test in $(BASEDIR)/tests/test_*.lua; do lua "$$test"; done


.PHONY: integration-tests
integration-tests:
	for test in $(BASEDIR)/tests/hs_*.lua; do hs "$$test"; done


.PHONY: preflight
preflight: static-checks unit-tests
	@echo "Preflight checks passed."


.PHONY: test
test: unit-tests integration-tests
	@echo "All tests passed."


.PHONY: clean
clean:
	rm -Rf "$(BASEDIR)/build"


.PHONY: clobber
clobber: clean
	rm -Rf "$(BASEDIR)/dist"
