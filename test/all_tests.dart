// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library quiver.all_tests;

import 'package:unittest/compact_vm_config.dart';

import 'async/all_tests.dart' as async;
import 'cache/map_cache_test.dart' as cache;
import 'collection/all_tests.dart' as collection;
import 'core/all_tests.dart' as core;
import 'io_test.dart' as io;
import 'iterables/all_tests.dart' as iterables;
import 'mirrors_test.dart' as mirrors;
import 'pattern/all_tests.dart' as pattern;
import 'streams/all_tests.dart' as streams;
import 'strings_test.dart' as strings;
import 'testing/all_tests.dart' as testing;
import 'time/all_tests.dart' as time;

main() {
  useCompactVMConfiguration();
  async.main();
  cache.main();
  collection.main();
  core.main();
  io.main();
  iterables.main();
  mirrors.main();
  pattern.main();
  streams.main();
  strings.main();
  testing.main();
  time.main();
}
