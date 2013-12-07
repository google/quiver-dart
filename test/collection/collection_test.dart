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

library quiver.collection.collection_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

main() {
  group('listEquals', () {
    test('return true for equal lists', () {
      expect(listEquals(null, null), isTrue);
      expect(listEquals([], []), isTrue);
      expect(listEquals([1], [1]), isTrue);
      expect(listEquals(['a', 'b'], ['a', 'b']), isTrue);
    });

    test('return false for non-equal lists', () {
      expect(listEquals(null, []), isFalse);
      expect(listEquals([], null), isFalse);
      expect(listEquals([1], [2]), isFalse);
      expect(listEquals([1], []), isFalse);
      expect(listEquals([], [1]), isFalse);
    });
  });

  group('listMap', () {
    test('return true for equal maps', () {
      expect(mapEquals(null, null), isTrue);
      expect(mapEquals({}, {}), isTrue);
      expect(mapEquals({'a': 1}, {'a': 1}), isTrue);
    });

    test('return false for non-equal maps', () {
      expect(mapEquals(null, {}), isFalse);
      expect(mapEquals({}, null), isFalse);
      expect(mapEquals({'a': 1}, {'a': 2}), isFalse);
      expect(mapEquals({'a': 1}, {'b': 1}), isFalse);
      expect(mapEquals({'a': 1}, {'a': 1, 'b': 2}), isFalse);
      expect(mapEquals({'a': 1, 'b': 2}, {'a': 1}), isFalse);
    });
  });
}
