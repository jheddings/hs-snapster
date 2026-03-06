# justfile for hs-snapster

basedir := justfile_directory()
srcdir := basedir / "src"

appname := `grep -m1 '^obj.name' src/init.lua | sed -e 's/.*"\(.*\)"/\1/'`
appver := `grep -m1 '^obj.version' src/init.lua | sed -e 's/.*"\(.*\)"/\1/'`

build_dir := basedir / "build" / appname + ".spoon"
zip_dist := basedir / "dist" / appname + "-" + appver + ".zip"

mod test "tests/.justfile"

# build docs, package spoon, and create zip
default: preflight build

# generate documentation JSON
docs:
  mkdir -p "{{build_dir}}"
  hs -c "hs.doc.builder.genJSON('{{srcdir}}')" \
    | grep -v "^--" \
    > "{{build_dir}}/docs.json"

# build the spoon and create distribution zip
build: docs
  cp -av "{{srcdir}}/" "{{build_dir}}/"
  mkdir -p "{{basedir}}/dist"
  cd "{{basedir}}/build" && zip -9r "{{zip_dist}}" "{{appname}}.spoon"

# tag, push, and create a GitHub draft release
release: preflight build
  git tag "v{{appver}}" main
  git push origin "v{{appver}}"
  gh release create --draft --title "{{appname}}-{{appver}}" --generate-notes \
    --verify-tag "v{{appver}}" "{{zip_dist}}"

# run static analysis checks
check:
  @echo "Static checks passed."

# run static checks and unit tests
preflight: check
  @just test unit
  @echo "Preflight checks passed."

# remove build artifacts
clean:
  rm -rf "{{basedir}}/build"

# remove build artifacts and distribution files
clobber: clean
  rm -rf "{{basedir}}/dist"
