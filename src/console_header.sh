#!/bin/bash

function console_header::print_version_with_env() {
  local filter=${1:-}
  local files=("${@:2}")
  local should_print_ascii="true"

  if [[ "$BASHUNIT_SHOW_HEADER" != "$should_print_ascii" ]]; then
    return
  fi

  console_header::print_version "$filter" "${files[@]}"
}

function console_header::print_version() {
  local filter=${1:-}
  if [[ -n "$filter" ]]; then
   shift
  fi

  local files=("$@")
  local total_tests
  if [[ ${#files[@]} -eq 0 ]]; then
    total_tests=0
  else
    total_tests=$(helpers::find_total_tests "$filter" "${files[@]}")
  fi

  if [[ $BASHUNIT_HEADER_ASCII_ART == true ]]; then
    cat <<EOF
 _               _                   _
| |__   __ _ ___| |__  __ __ ____ (_) |_
| '_ \ / _' / __| '_ \| | | | '_ \| | __|
| |_) | (_| \__ \ | | | |_| | | | | | |_
|_.__/ \__,_|___/_| |_|\___/|_| |_|_|\__|
EOF
    if [ "$total_tests" -eq 0 ]; then
      printf "%s\n" "$BASHUNIT_VERSION"
    else
      printf "%s | Total tests: %s\n" "$BASHUNIT_VERSION" "$total_tests"
    fi
    return
  fi

  if [ "$total_tests" -eq 0 ]; then
    printf "${_COLOR_BOLD}${_COLOR_PASSED}bashunit${_COLOR_DEFAULT} - %s\n" "$BASHUNIT_VERSION"
  else
    printf "${_COLOR_BOLD}${_COLOR_PASSED}bashunit${_COLOR_DEFAULT} - %s | Total tests: %s\n"\
      "$BASHUNIT_VERSION"\
      "$total_tests"
  fi
}

function console_header::print_help() {
    cat <<EOF
bashunit [arguments] [options]

Arguments:
  Specifies the directory or file containing the tests to run.
  If a directory is specified, it will execute the tests within files ending with test.sh.
  If you use wildcards, bashunit will run any tests it finds.

Options:
  -a|--assert <function ...args>
    Run a core assert function standalone without a test context.

  --debug
    Print all executed shell commands to the terminal.

  -e|--env <file-path>
    Load a custom env file overriding the .env environment variables.

  -f|--filter <filter>
    Filters the tests to run based on the test name.

  -l|--log-junit <out.xml>
    Create a report JUnit XML file that contains information about the test results.

  -r|--report-html <out.html>
    Create a report HTML file that contains information about the test results.

  -s|simple || -v|verbose
    Enables simplified or verbose output to the console.

  -S|--stop-on-failure
    Force to stop the runner right after encountering one failing test.

  --version
    Displays the current version of bashunit.

  --upgrade
    Upgrade to latest version of bashunit.

  --help
    This message.

See more: https://bashunit.typeddevs.com/command-line
EOF
}

function console_header::print_total_tests() {
  local files=("${@}")

  local total_tests
  total_tests=$(helpers::find_total_tests "${files[@]}")
  printf "\rTotal tests: %s\n" "$total_tests"
}
