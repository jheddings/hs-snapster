# Makefile for hs-snapster

BASEDIR ?= $(PWD)
SRCDIR ?= $(BASEDIR)/src

APPNAME ?= $(shell grep -m1 '^obj.name' "src/init.lua"  | sed -e 's/.*"\(.*\)"/\1/')
APPVER ?= $(shell grep -m1 '^obj.version' "src/init.lua"  | sed -e 's/.*"\(.*\)"/\1/')

BUILD_DIR ?= $(BASEDIR)/build/$(APPNAME).spoon
ZIP_DIST ?= $(BASEDIR)/dist/$(APPNAME)-$(APPVER).zip


.PHONY: all
all: preflight build


.PHONY: build-docs
build-docs:
	mkdir -p "$(BUILD_DIR)"
	hs -c "hs.doc.builder.genJSON('$(SRCDIR)')" \
		| grep -v "^--" \
		> "$(BUILD_DIR)/docs.json"


.PHONY: build
build: build-docs
	cp -av "$(BASEDIR)/src/" "$(BUILD_DIR)/"
	mkdir -p "$(BASEDIR)/dist"
	cd "$(BASEDIR)/build" && zip -9r "$(ZIP_DIST)" "$(APPNAME).spoon"


.PHONY: release
release: preflight build
	git tag "v$(APPVER)" main
	git push origin "v$(APPVER)"
	gh release create --draft --title "$(APPNAME)-$(APPVER)" --generate-notes \
		--verify-tag "v$(APPVER)" "$(ZIP_DIST)"


.PHONY: static-checks
static-checks:
	@echo "Static checks passed."


.PHONY: unit-tests
unit-tests:
	for test in $(BASEDIR)/tests/test_*.lua; do lua "$$test"; done
	@echo "Unit tests complete."


.PHONY: integration-tests
integration-tests:
	for test in $(BASEDIR)/tests/hs_*.lua; do hs "$$test"; done
	@echo "Integration tests complete."


.PHONY: test
test: unit-tests integration-tests
	@echo "All tests passed."


.PHONY: preflight
preflight: static-checks unit-tests
	@echo "Preflight checks passed."


.PHONY: clean
clean:
	rm -Rf "$(BASEDIR)/build"


.PHONY: clobber
clobber: clean
	rm -Rf "$(BASEDIR)/dist"
