# test tasks for hs-snapster

basedir := justfile_directory()
libdir := basedir / "lib"

# run default test suite
default: unit

# run all tests (alias)
all: unit integration
  @echo "All tests passed."

# run unit tests
unit:
  cd "{{basedir}}" && for test in tests/test_*.lua; do LUA_PATH="{{libdir}}/?.lua;;" lua "$test"; done
  @echo "Unit tests complete."

# run integration tests (requires Hammerspoon)
integration:
  cd "{{basedir}}" && for test in tests/hs_*.lua; do hs "$test"; done
  @echo "Integration tests complete."
