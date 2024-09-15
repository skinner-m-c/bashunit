#!/bin/bash

__ORIGINAL_OS=""



function set_up_before_script() {
  __ORIGINAL_OS=$_OS
  source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

}

function tear_down_after_script() {
  export _OS=$__ORIGINAL_OS
}



function test_now_with_perl() {
  mock dependencies::has_perl  mock_true
  mock dependencies::has_adjtimex  mock_false
  mock perl echo "1720705883457"

  assert_same "1720705883457" "$(clock::now)"
}

function test_now_on_linux_without_perl() {

  export _OS="Linux"
  mock perl mock_non_existing_fn
  mock dependencies::has_perl  mock_false
  mock dependencies::has_adjtimex  mock_false

  mock date echo "1720705883457"

  assert_same "1720705883457" "$(clock::now)"
}
function test_now_on_windows_without_perl_and_adjtimex() {

  export _OS="Windows"
  mock dependencies::has_perl  mock_false
  mock dependencies::has_adjtimex  mock_false
  mock perl mock_non_existing_fn
  mock date echo "1720705883457"

  assert_same "1720705883457" "$(clock::now)"
}

function test_now_on_osx_without_perl_and_adjtimex() {
  export _OS="OSX"

  mock dependencies::has_perl  mock_true
  mock dependencies::has_adjtimex  mock_false
  mock perl mock_non_existing_fn

  assert_same "" "$(clock::now)"
}

function test_now_on_alpine_with_adjtimex() {
   export _OS="Linux/Alpine"
   mock dependencies::has_perl  mock_false
   mock dependencies::has_adjtimex  mock_true
   mock_ajdtimex

  assert_same "1726352475380500672" "$(clock::now)"
}

function mock_ajdtimex() {
     mock adjtimex << EOF
      mode:         0
  -o  offset:       0 us
  -f  freq.adjust:  -375561 (65536 = 1ppm)
      maxerror:     40032
      esterror:     2430
      status:       8192 ()
  -p  timeconstant: 2
      precision:    1 us
      tolerance:    32768000
  -t  tick:         10000 us
      time.tv_sec:  1726352475
      time.tv_usec: 380500672
      return value: 0 (clock synchronized)
EOF
}



function test_runtime_in_milliseconds_when_not_empty_time() {
  mock perl echo "1720705883457"

  assert_not_empty "$(clock::runtime_in_milliseconds)"
}


function test_runtime_in_milliseconds_when_empty_time() {
  export _OS="OSX"
  mock perl mock_non_existing_fn
  mock dependencies::has_perl  mock_false
  mock dependencies::has_adjtimex  mock_false

  assert_empty "$(clock::runtime_in_milliseconds)"
}
