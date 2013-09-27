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

library quiver.collection.all_tests;

import 'bimap_test.dart' as bimap;
import 'listed_test.dart' as listed;
import 'mapped_test.dart' as mapped;
import 'multimap_test.dart' as multimap;
import 'setted_test.dart' as setted;
import 'delegates/iterable_test.dart' as iterable;
import 'delegates/list_test.dart' as list;
import 'delegates/map_test.dart' as map;
import 'delegates/queue_test.dart' as queue;
import 'delegates/set_test.dart' as set;

main() {
  bimap.main();
  mapped.main();
  multimap.main();
  iterable.main();
  list.main();
  listed.main();
  map.main();
  queue.main();
  set.main();
  setted.main();
}
