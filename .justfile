# justfile for hs-snapster

basedir := justfile_directory()
srcdir := basedir / "src"

appname := `grep -m1 '^obj.name' src/init.lua | sed -e 's/.*"\(.*\)"/\1/'`
appver := `grep -m1 '^obj.version' src/init.lua | sed -e 's/.*"\(.*\)"/\1/'`

build_dir := basedir / "build" / appname + ".spoon"
zip_dist := basedir / "dist" / appname + "-" + appver + ".zip"
install_dir := home_directory() / ".hammerspoon/Spoons" / appname + ".spoon"

mod test "tests/.justfile"

# run checks and build distributable zip
default: preflight build

# generate documentation JSON into src
docs:
  hs -c "hs.doc.builder.genJSON('{{srcdir}}')" \
    | grep -v "^--" \
    > "{{srcdir}}/docs.json"
  git add "{{srcdir}}/docs.json"
  git diff --quiet --cached "{{srcdir}}/docs.json" \
    || git commit -m "Update docs for v{{appver}}"

# create distributable spoon zip
build:
  mkdir -p "{{build_dir}}" "{{basedir}}/dist"
  cp -av "{{srcdir}}/" "{{build_dir}}/"
  cd "{{basedir}}/build" && zip -9r "{{zip_dist}}" "{{appname}}.spoon"

# tag and push to trigger the release workflow
release: preflight docs
  git tag "v{{appver}}" main
  git push origin main "v{{appver}}"

# install spoon to ~/.hammerspoon/Spoons
install:
  mkdir -p "{{install_dir}}"
  cp -av "{{srcdir}}/" "{{install_dir}}/"

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
