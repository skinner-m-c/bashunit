#!/bin/bash

function set_up_before_script() {
  source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
}

function test_default_os() {
  mock uname echo "bogus OS"

  check_os::init
  assert_equals  "Unknown" "$_OS"
}

function test_detect_linux_os() {
  mock uname echo "Linux"
  mock grep mock_non_existing_fn

  check_os::init
  assert_equals "Linux" "$_OS"
}

function test_detect_alpine_linux_os() {
  mock uname echo "Linux"
  mock check_os::is_alpine mock_true
  check_os::init

  assert_equals  "Linux/Alpine" "$_OS"
}

# data_provider alpine_os_release
function test_detect_alpine_os_file() {
  local alpine_os_release="$1"

  assert_successful_code "$(check_os::is_alpine "$alpine_os_release")"
}

function alpine_os_release() {
  echo "$(dirname "${BASH_SOURCE[0]}")/fixtures/os-release/alpine-1.txt"
}

# data_provider not_alpine_os_release
function test_detect_not_alpine_os() {
   local alpine_os_release="$1"

   assert_general_error "$(check_os::is_alpine "$alpine_os_release")"
}

function not_alpine_os_release() {
  echo "$(dirname "${BASH_SOURCE[0]}")/fixtures/os-release/alpine-bad-1.txt"
}

function test_detect_osx_os() {
  mock uname echo "Darwin"

  check_os::init
  assert_equals "OSX" "$_OS"
}

# data_provider window_linux_variations
function test_detect_windows_os() {
  local windows_linux="$1"
  mock uname echo "$windows_linux"

  check_os::init
  assert_equals "Windows" "$_OS"
}

function window_linux_variations() {
  echo "MINGW"
  echo "junkMINGWjunk"
}

# data_provider alpine_os_release
function test_alpine_is_busybox() {
  local alpine_os_release="$1"

 mock uname echo "Linux"
 assert_successful_code "$(check_os::is_alpine "$alpine_os_release")"
 mock check_os::is_alpine mock_true
 check_os::init
 assert_successful_code "$(check_os::is_busybox)"
}

# data_provider not_alpine_os_release
function test_not_alpine_is_not_busybox() {
   local alpine_os_release="$1"

   mock uname echo "Linux"
   assert_general_error "$(check_os::is_alpine "$alpine_os_release")"
   mock check_os::is_alpine mock_false
   check_os::init
   assert_general_error "$(check_os::is_busybox)"
}
