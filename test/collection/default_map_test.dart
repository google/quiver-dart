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

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

main() {
  final map = { 1: 'Hello', 3: null };
  final orElse = () => 'World';

  group('getOrElse', () {
    test('getOrElse returns a value normally if the key exists', () {
      expect(getOrElse(map, 1, orElse), 'Hello');
    });

    test('getOrElse returns a closure\'s value if the key does not exist', () {
      expect(getOrElse(map, 2, orElse), 'World');
    });

    test('getOrElse returns null if it\'s the value set', () {
      expect(getOrElse(map, 3, orElse), null);
    });
  });

  group('DefaultMap', () {
    final defaultMap = new DefaultMap(map);

    test('getOrElse returns a value normally if the key exists', () {
      expect(defaultMap.getOrElse(1, orElse), 'Hello');
    });

    test('getOrElse returns a closure\'s value if the key does not exist', () {
      expect(defaultMap.getOrElse(2, orElse), 'World');
    });

    test('getOrElse returns null if it\'s the value set', () {
      expect(defaultMap.getOrElse(3, orElse), null);
    });
  });
}
