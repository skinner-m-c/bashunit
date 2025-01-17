#!/bin/bash

function test_successful_assert_file_exists() {
  local a_file
  a_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

  assert_empty "$(assert_file_exists "$a_file")"
}

function test_unsuccessful_assert_file_exists() {
  local a_file="a_random_file_that_will_not_exist"

  assert_same\
    "$(console_results::print_failed_test "Unsuccessful assert file exists" "$a_file" "to exist but" "do not exist")"\
    "$(assert_file_exists "$a_file")"
}

function test_assert_file_exists_should_not_work_with_folders() {
  local a_dir
  a_dir="$(dirname "${BASH_SOURCE[0]}")"

  assert_same\
    "$(console_results::print_failed_test \
      "Assert file exists should not work with folders" "$a_dir" "to exist but" "do not exist")"\
    "$(assert_file_exists "$a_dir")"
}

function test_successful_assert_file_not_exists() {
  local a_file="a_random_file_that_will_not_exist"

  assert_empty "$(assert_file_not_exists "$a_file")"
}

function test_unsuccessful_assert_file_not_exists() {
  local a_file
  a_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

  assert_same\
    "$(console_results::print_failed_test\
      "Unsuccessful assert file not exists" "$a_file" "to not exist but" "the file exists")"\
    "$(assert_file_not_exists "$a_file")"
}

function test_successful_assert_is_file() {
  local a_file
  a_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

  assert_empty "$(assert_is_file "$a_file")"
}

function test_unsuccessful_assert_is_file() {
  local a_file="a_random_file_that_will_not_exist"

  assert_same\
    "$(console_results::print_failed_test "Unsuccessful assert is file" "$a_file" "to be a file" "but is not a file")"\
    "$(assert_is_file "$a_file")"
}

function test_unsuccessful_assert_is_file_when_a_folder_is_given() {
  local a_folder
  a_folder="$(dirname "${BASH_SOURCE[0]}")"

  assert_same\
    "$(console_results::print_failed_test\
      "Unsuccessful assert is file when a folder is given" "$a_folder" "to be a file" "but is not a file")"\
    "$(assert_is_file "$a_folder")"
}

function test_successful_assert_is_file_empty() {
  local path="/tmp/a_random_file_$(date +%s)"
  touch "$path"

  assert_empty "$(assert_is_file_empty "$path")"

  rm "$path"
}

function test_unsuccessful_assert_is_file_empty() {
  local a_file
  a_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

  assert_same\
    "$(console_results::print_failed_test\
      "Unsuccessful assert is file empty" "$a_file" "to be empty" "but is not empty")"\
    "$(assert_is_file_empty "$a_file")"
}

# shellcheck disable=SC2155
function test_successful_assert_files_equals() {
  datetime=$(date +%s)
  local expected="/tmp/a_random_file_${datetime}_1"
  local actual="/tmp/a_random_file_${datetime}_2"

  local file_content="My multiline file
  Special char: \$, \*, and \\

  another extra line"

  echo "$file_content" > "$expected"
  echo "$file_content" > "$actual"

  assert_empty "$(assert_files_equals "$expected" "$actual")"

  rm "$expected"
  rm "$actual"
}

# shellcheck disable=SC2155
function test_fails_assert_files_equals() {
  datetime=$(date +%s)
  local expected="/tmp/a_random_file_${datetime}_1"
  local actual="/tmp/a_random_file_${datetime}_2"

  echo -e "same\noriginal content" > "$expected"
  echo -e "same\ndifferent content" > "$actual"

  actual="$(assert_files_equals "$expected" "$actual")"
  assert_contains "Fails assert files equals" "$actual"

  rm "$expected"
  rm "$actual"
}

# shellcheck disable=SC2155
function test_successful_assert_files_not_equals() {
  local expected="/tmp/test_successful_assert_files_not_equals_1"
  local actual="/tmp/test_successful_assert_files_not_equals_2"

  echo -e "same\noriginal content" > "$expected"
  echo -e "same\ndifferent content" > "$actual"

  assert_empty "$(assert_files_not_equals "$expected" "$actual")"

  rm "$expected"
  rm "$actual"
}

# shellcheck disable=SC2155
function test_fails_assert_files_not_equals() {
  local expected="/tmp/test_fails_assert_files_not_equals"
  local actual="/tmp/test_fails_assert_files_not_equals"

  echo -e "same content" > "$expected"
  echo -e "same content" > "$actual"

  actual="$(assert_files_not_equals "$expected" "$actual")"
  assert_contains "Files are equals" "$actual"

  rm "$expected"
  rm "$actual"
}
