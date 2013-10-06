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

library quiver.collection.lists_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';
import 'dart:math' show Random;


main() {
  group('Shuffle', () {
    test('a list with a provided Random', () {
      List originalList = [1,2,3,4,5];
      List list = new List.from(originalList);
      shuffle(list, new Random(1));
      expect(list, isNot(equals(originalList)));
      expect(list, equals([5, 3, 2, 4, 1]));
    });
    test('a list with its own Random', () {
      List originalList = [1,2,3,4,5];
      List list = new List.from(originalList);
      shuffle(list);
      expect(list, isNot(equals(originalList)));
      expect(list, unorderedEquals(originalList));
    });
  });
}
