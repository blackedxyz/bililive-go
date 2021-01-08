#!/bin/sh

set -o errexit
set -o nounset

BIN_PATH=bin

package() {
  pushd $BIN_PATH >/dev/null 2>&1
  file=$1
  type=$2
  case $type in
  zip)
    zip ${file%.exe}.zip ${file} ../config.yml
    ;;
  tar)
    tar zcvf ${file}.tar.gz ${file} -C ../ config.yml
    ;;
  7z)
    7z a ${file}.7z ${file} ../config.yml
    ;;
  *) ;;

  esac
  popd >/dev/null 2>&1
}

for dist in $(go tool dist list); do
  if [[ $dist == android/* || $dist == darwin/arm64 || $dist == js/wasm ]]; then
    continue
  fi
  platform=$(echo ${dist} | cut -d'/' -f1)
  arch=$(echo ${dist} | cut -d'/' -f2)
  make PLATFORM=${platform} ARCH=${arch} bililive
done

for file in $(ls $BIN_PATH); do
  if [[ $file == *".tar.gz" || $file == *".zip" || $file == *".7z" || $file == *".yml" ]]; then
    continue
  fi
  package_type=tar
  if [[ $file == *"windows"* ]]; then
    package_type=zip
  fi
  package $file $package_type
  rm -f $BIN_PATH/$file
done
