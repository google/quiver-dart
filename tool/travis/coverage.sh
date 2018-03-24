#!/bin/bash

# Copyright (c) 2018, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Gather and send coverage data.
if [ "$COVERALLS_REPO_TOKEN" ] && [ "$TRAVIS_DART_VERSION" = "dev" ]; then
  pub global activate coverage ">=0.10.0"

  OBS_PORT=9292
  echo "Collecting coverage on port $OBS_PORT..."

  # Start tests in one VM.
  echo "Starting tests..."
  dart \
    --enable-vm-service=$OBS_PORT \
    --pause-isolates-on-exit \
    test/all_tests.dart &

  # Run the coverage collector to generate the JSON coverage report.
  echo "Collecting coverage..."
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

  echo "Uploading to Coveralls..."
  coveralls-lcov --repo-token="$COVERALLS_REPO_TOKEN" var/lcov.info
fi
