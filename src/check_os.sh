#!/bin/bash

_OS="Unknown"


function check_os::init() {
  # shellcheck disable=SC2034
  _OS="Unknown"

  if [[ "$(uname)" == "Linux" ]]; then
    _OS="Linux"

    if check_os::is_alpine ""; then
      _OS="Linux/Alpine"
    fi

  elif [[ "$(uname)" == "Darwin" ]]; then
    _OS="OSX"
  elif [[ $(uname) == *"MINGW"* ]]; then
    _OS="Windows"
  fi
}

function check_os::is_alpine() {
  local file_with_alpine="$1"

  if [[ -z "$file_with_alpine" ]]; then
    file_with_alpine="/etc/os-release"
  fi

  grep -iq "alpine" "$file_with_alpine"
}

function check_os::is_busybox() {

  case "$_OS" in

    "Linux/Alpine")
        return 0
        ;;
    *)
      return 1
      ;;
  esac
}

check_os::init
