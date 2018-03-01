#!/bin/bash

# Copyright (c) 2018, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

if [ "$#" == "0" ]; then
  echo -e '\033[31mAt least one task argument must be provided!\033[0m'
  exit 1
fi

EXIT_CODE=0

while (( "$#" )); do
  TASK=$1
  case $TASK in
  dartfmt) echo
    echo -e '\033[1mTASK: dartfmt\033[22m'
    echo -e 'dartfmt -n --set-exit-if-changed .'
    dartfmt -n --set-exit-if-changed . || EXIT_CODE=$?
    ;;
  dartanalyzer) echo
    echo -e '\033[1mTASK: dartanalyzer\033[22m'
    echo -e 'dartanalyzer --fatal-warnings .'
    dartanalyzer --fatal-warnings . || EXIT_CODE=$?
    ;;
  vm_test) echo
    echo -e '\033[1mTASK: vm_test\033[22m'
    echo -e 'pub run test -p vm'
    pub run test -p vm || EXIT_CODE=$?
    ;;
  dartdevc_build) echo
    echo -e '\033[1mTASK: build\033[22m'
    echo -e 'pub run build_runner build --fail-on-severe'
    pub run build_runner build --fail-on-severe || EXIT_CODE=$?
    ;;
  dartdevc_test) echo
    echo -e '\033[1mTASK: dartdevc_test\033[22m'
    echo -e 'pub run build_runner test -- -p chrome'
    pub run build_runner test -- -p chrome -x fails-on-dartdevc || EXIT_CODE=$?
    ;;
  dart2js_test) echo
    echo -e '\033[1mTASK: dart2js_test\033[22m'
    echo -e 'pub run test -p chrome'
    pub run test -p chrome -x fails-on-dart2js || EXIT_CODE=$?
    ;;
  *) echo -e "\033[31mNot expecting TASK '${TASK}'. Error!\033[0m"
    EXIT_CODE=1
    ;;
  esac

  shift
done

exit $EXIT_CODE
