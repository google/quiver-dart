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

# Run the tests.
echo "Running tests..."
dart -c test/all_tests.dart
