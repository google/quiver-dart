#!/bin/bash

# Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Verify that the libraries are error and warning-free.
echo "Running dartanalyzer..."
libs=$(find lib -maxdepth 1 -type f -name '*.dart')
testing_libs=$(find lib/testing -maxdepth 1 -type f -name '*.dart')
dartanalyzer $DARTANALYZER_FLAGS $libs $testing_libs test/all_tests.dart

# Verify that dartfmt has been run
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
pub run test:test

# Gather and send coverage data.
if [ "$REPO_TOKEN" ] && [ "$TRAVIS_DART_VERSION" = "stable" ]; then
  echo "Collecting coverage..."
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $REPO_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/all_tests.dart
fi
