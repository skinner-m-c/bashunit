#!/bin/bash
set -euo pipefail

__ORIGINAL_DEPENDENCY_PERL=""
__ORIGINAL_DEPENDENCY_ADJTIMEX=""
__ORIGINAL_DEPENDENCY_BC=""
__ORIGINAL_DEPENDENCY_AWK=""

function set_up_before_script() {
  __ORIGINAL_DEPENDENCY_PERL="$_DEPENDENCY_PERL"
  __ORIGINAL_DEPENDENCY_ADJTIMEX="$_DEPENDENCY_ADJTIMEX"
  __ORIGINAL_DEPENDENCY_BC="$_DEPENDENCY_BC"
  __ORIGINAL_DEPENDENCY_AWK="$_DEPENDENCY_AWK"


}

function tear_down_after_script() {
   export DEPENDENCY_PERL="$__ORIGINAL_DEPENDENCY_PERL"
   export DEPENDENCY_ADJTIMEX="$__ORIGINAL_DEPENDENCY_ADJTIMEX"
   export DEPENDENCY_BC="$__ORIGINAL_DEPENDENCY_BC"
   export DEPENDENCY_AWK="$__ORIGINAL_DEPENDENCY_AWK"
}


function test_has_perl_search_path_for_perl() {
  spy which
  _DEPENDENCY_PERL=""
  dependencies::has_perl

  assert_have_been_called_with "perl" which
}

# data_provider dependency_function_list
function test_which_called_once_for_dependency_checks() {
  local function_name="$1"

  assert_which_called_once "$function_name"
}


function test_has_adjtimex() {
  spy which
  _DEPENDENCY_ADJTIMEX=""
  dependencies::has_adjtimex

  assert_have_been_called_with "adjtimex" which
}


function test_has_bc() {
  spy which
  _DEPENDENCY_BC=""

  dependencies::has_bc

  assert_have_been_called_with "bc" which
}

function test_has_awk() {
  spy which
  _DEPENDENCY_AWK=""
  dependencies::has_awk

  assert_have_been_called_with "awk" which
}

function test_has_git() {
  spy which
  _DEPENDENCY_AWK=""
  dependencies::has_git

  assert_have_been_called_with "git" which
}


function dependency_function_list() {
  echo "dependencies::has_perl"
  echo "dependencies::has_adjtimex"
  echo "dependencies::has_bc"
  echo "dependencies::has_awk"
  echo "dependencies::has_git"
}


function assert_which_called_once() {
  local func_name="$1"
  local call_count=0

   label="$(helper::normalize_test_function_name "${FUNCNAME[1]}")"
    function which_func() {
      call_count=$(( call_count + 1 ))
    }


    mock which which_func

    eval "$func_name"
    eval "$func_name"

  if [[ call_count -gt 1 ]]; then
     state::add_assertions_failed
            console_results::print_failed_test "$label" "which" "to be called" "1" "instead it was called" "$call_count"
            return
  fi
}

function test_init_which_called_once() {
  function do_not_cache() {
    which ls
  }
 assert_same\
    "$(console_results::print_failed_test \
      "Init which called once" \
      "which" "to be called" "1" "instead it was called" "2")"\
    "$(assert_which_called_once "do_not_cache")"

}
