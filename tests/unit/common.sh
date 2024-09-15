#!/bin/bash


function mock_non_existing_fn() {
  return 127;
}

function mock_false() {
  return 1;
}

function mock_true() {
  return 0;
}

export -f mock_non_existing_fn
export -f mock_false
export -f mock_true
