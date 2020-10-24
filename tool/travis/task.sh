#!/bin/bash

# Copyright 2018 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ "$#" == "0" ]; then
  echo -e '\033[31mAt least one task argument must be provided!\033[0m'
  echo -e 'Valid tasks: dartfmt dartanalyzer vm_test dart2js_test dartdevc_test'
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
    pub run test -p vm -r expanded || EXIT_CODE=$?
    ;;
  dart2js_test) echo
    echo -e '\033[1mTASK: dart2js_test\033[22m'
    echo -e 'pub run test -p chrome -x fails-on-dart2js'
    pub run test -p chrome -x fails-on-dart2js -r expanded || EXIT_CODE=$?
    ;;
  dartdevc_test) echo
    echo -e '\033[1mTASK: dartdevc_test\033[22m'
    ./tool/travis/ddc_test.sh -p chrome -x fails-on-dartdevc -r expanded || EXIT_CODE=$?
    ;;
  *) echo -e "\033[31mUnknown task: '${TASK}'. Error!\033[0m"
    EXIT_CODE=1
    ;;
  esac

  shift
done

exit $EXIT_CODE
