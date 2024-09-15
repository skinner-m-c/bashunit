#!/bin/bash

declare -r BASHUNIT_GIT_REPO="https://github.com/TypedDevs/bashunit"

#
# @param $1 string Eg: "test_some_logic_camelCase"
#
# @return string Eg: "Some logic camelCase"
#
function helper::normalize_test_function_name() {
  local original_function_name="${1-}"
  local result

  # Remove "test_" prefix
  result="${original_function_name#test_}"
  # Replace underscores with spaces
  result="${result//_/ }"
  # Remove "test" prefix
  result="${result#test}"
  # Capitalize the first letter
  result="$(tr '[:lower:]' '[:upper:]' <<< "${result:0:1}")${result:1}"

  echo "$result"
}

function helper::check_duplicate_functions() {
  local script="$1"

  local filtered_lines
  filtered_lines=$(grep -E '^\s*(function)?\s*test[a-zA-Z_][a-zA-Z_0-9]*\s*\(\)?\s*\{' "$script")

  local function_names
  function_names=$(echo "$filtered_lines" | awk '{gsub(/\(|\)/, ""); print $2}')

  local sorted_names
  sorted_names=$(echo "$function_names" | sort)

  local duplicates
  duplicates=$(echo "$sorted_names" | uniq -d)
  if [ -n "$duplicates" ]; then
    state::set_duplicated_functions_merged "$script" "$duplicates"
    return 1
  fi
}

#
# @param $1 string Eg: "prefix"
# @param $2 string Eg: "filter"
# @param $3 array Eg: "[fn1, fn2, prefix_filter_fn3, fn4, ...]"
#
# @return array Eg: "[prefix_filter_fn3, ...]" The filtered functions with prefix
#
function helper::get_functions_to_run() {
  local prefix=$1
  local filter=${2/test_/}
  local function_names=$3

  local filtered_functions=""

  for fn in $function_names; do
    if [[ $fn == ${prefix}_*${filter}* ]]; then
      if [[ $filtered_functions == *" $fn"* ]]; then
        return 1
      fi
      filtered_functions+=" $fn"
    fi
  done

  echo "${filtered_functions# }"
}

#
# @param $1 string Eg: "do_something"
#
function helper::execute_function_if_exists() {
  if [[ "$(type -t "$1")" == "function" ]]; then
    "$1" 2>/dev/null
  fi
}

#
# @param $1 string Eg: "do_something"
#
function helper::unset_if_exists() {
  unset "$1" 2>/dev/null
}

function helper::find_files_recursive() {
  ## Remove trailing slash using parameter expansion
  local path="${1%%/}"

  if [[ "$path" == *"*"* ]]; then
    eval find "$path" -type f -name '*[tT]est.sh' | sort | uniq
  elif [[ -d "$path" ]]; then
    find "$path" -type f -name '*[tT]est.sh' | sort | uniq
  else
    echo "$path"
  fi
}

helper::normalize_variable_name() {
  local input_string="$1"
  local normalized_string

  normalized_string="${input_string//[^a-zA-Z0-9_]/_}"

  if [[ ! $normalized_string =~ ^[a-zA-Z_] ]]; then
    normalized_string="_$normalized_string"
  fi

  echo "$normalized_string"
}

function helper::get_provider_data() {
  local function_name="$1"
  local script="$2"
  local data_provider_function

  if [[ ! -f "$script" ]]; then
    return
  fi

  data_provider_function=$(\
    grep -B 1 "function $function_name()" "$script" |\
    grep "# data_provider " |\
    sed -E -e 's/\ *# data_provider (.*)$/\1/g'\
    || true
  )

  if [[ -n "$data_provider_function" ]]; then
    helper::execute_function_if_exists "$data_provider_function"
  fi
}

function helper::trim() {
  local input_string="$1"
  local trimmed_string

  trimmed_string="${input_string#"${input_string%%[![:space:]]*}"}"
  trimmed_string="${trimmed_string%"${trimmed_string##*[![:space:]]}"}"

  echo "$trimmed_string"
}

function helpers::get_latest_tag() {
  git ls-remote --tags "$BASHUNIT_GIT_REPO" |
    awk '{print $2}' |
    sed 's|^refs/tags/||' |
    sort -Vr |
    head -n 1
}

function helpers::find_total_tests() {
    local filter=${1:-}
    local files=("${@:2}")
    local total_count=0

    for file in "${files[@]}"; do
        local count
        if [[ -n "$filter" ]]; then
            count=$(grep -r -E "^\s*function\s+test.*$filter" "$file" --include=\*.sh 2>/dev/null | wc -l)
        else
            count=$(grep -r -E '^\s*function\s+test' "$file" --include=\*.sh 2>/dev/null | wc -l)
        fi
        total_count=$((total_count + count))
    done

    echo "$total_count"
}


function helper::load_test_files() {
  local filter=$1
  local files=("${@:2}")

  local test_files=()

  if [[ "${#files[@]}" -eq 0 ]]; then
    if [[ -n "${BASHUNIT_DEFAULT_PATH}" ]]; then
      while IFS='' read -r line; do
        test_files+=("$line")
      done < <(helper::find_files_recursive "$BASHUNIT_DEFAULT_PATH")
    fi
  else
    test_files=("${files[@]}")
  fi

  printf "%s\n" "${test_files[@]}"
}
