#!/bin/bash

# Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Run pub get to fetch dependencies.
echo "Running pub get..."
pub get

# Verify that the libraries are error and warning-free.
echo "Running dartanalyzer..."
libs=$(find lib -maxdepth 1 -type f -name '*.dart')
testing_libs=$(find lib/testing -maxdepth 1 -type f -name '*.dart')
dartanalyzer $DARTANALYZER_FLAGS $libs $testing_libs test/all_tests.dart

# Verify that dartfmt has been run.
if [[ "$TRAVIS_DART_VERSION" == "stable" ]]; then
  # Only test on stable to avoid CI failure due to diffs between stable and dev.
  echo "Checking dartfmt..."
  if [[ $(dartfmt -n --set-exit-if-changed lib/ test/) ]]; then
    echo "Failed dartfmt check: run dartfmt -w lib/ test/"
    exit 1
  fi
fi

# Run the tests.
echo "Running tests..."
pub run test:test --reporter expanded

# Gather and send coverage data.
if [ "$REPO_TOKEN" ] && [ "$TRAVIS_DART_VERSION" = "stable" ]; then
  OBS_PORT=9292
  echo "Collecting coverage on port $OBS_PORT..."

  # Start tests in one VM.
  dart \
    --enable-vm-service=$OBS_PORT \
    --pause-isolates-on-exit \
    test/all_tests.dart &

  # Run the coverage collector to generate the JSON coverage report.
  pub global activate coverage
  pub global run coverage:collect_coverage \
    --port=$OBS_PORT \
    --out=var/coverage.json \
    --wait-paused \
    --resume-isolates

  echo "Generating LCOV report..."
  pub global run coverage:format_coverage \
    --lcov \
    --in=var/coverage.json \
    --out=var/lcov.info \
    --packages=.packages \
    --report-on=lib
fi
