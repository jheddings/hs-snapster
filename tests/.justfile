# test tasks for hs-snapster

basedir := justfile_directory()

# run all tests
default: unit integration
  @echo "All tests passed."

# run all tests (alias)
all: default

# run unit tests
unit:
  for test in {{basedir}}/tests/test_*.lua; do lua "$test"; done
  @echo "Unit tests complete."

# run integration tests (requires Hammerspoon)
integration:
  for test in {{basedir}}/tests/hs_*.lua; do hs "$test"; done
  @echo "Integration tests complete."
