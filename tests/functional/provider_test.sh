#!/bin/bash
set -euo pipefail

_TEST_GET_DATA_FROM_PROVIDER_ITERATION_FILE=""

function set_up_before_script() {
  _TEST_GET_DATA_FROM_PROVIDER_ITERATION_FILE=$(mktemp)
  echo 0 > "$_TEST_GET_DATA_FROM_PROVIDER_ITERATION_FILE"
}

function tear_down_after_script() {
  rm "$_TEST_GET_DATA_FROM_PROVIDER_ITERATION_FILE"
}

function set_up() {
  _GLOBAL="aa-bb"
}

# data_provider provide_multiples_values
function test_multiple_values_from_data_provider() {
  local first=$1
  local second=$2

  assert_equals "${_GLOBAL}" "$first-$second"
}

function provide_multiples_values() {
  echo "aa" "bb"
  echo "aa" "bb"
}

# data_provider provide_single_values
function test_single_values_from_data_provider() {
  local current_data="$1"
  local current_iteration=0

  local stored_iteration
  stored_iteration=$(cat "$_TEST_GET_DATA_FROM_PROVIDER_ITERATION_FILE")
  stored_iteration=$(( stored_iteration + 1))
  echo -n "$stored_iteration" > "$_TEST_GET_DATA_FROM_PROVIDER_ITERATION_FILE"

  current_iteration=$(cat "$_TEST_GET_DATA_FROM_PROVIDER_ITERATION_FILE")

  case $current_iteration in
    1)
      assert_same "one" "$current_data"
      ;;
    2)
      assert_same "two" "$current_data"
      ;;
    3)
      assert_same "three" "$current_data"
      ;;
    *)
      fail
      ;;
  esac
}

function provide_single_values() {
  echo "one"
  echo "two"
  echo "three"
}

# data_provider provide_single_value
function test_single_value_from_data_provider() {
  local current_data="$1"

  assert_same "one" "$current_data"
}

function provide_single_value() {
  echo "one"
}
