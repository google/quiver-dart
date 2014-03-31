// Copyright 2014 Google Inc. All Rights Reserved.
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

library quiver.compare.sorted_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/compare.dart';

main() {

  group('sorted', () {

    test('should return a sorted copy', () {
      expect(sorted([2, 1, 3]), [1, 2, 3]);
    });

    test('should respect growable', () {
      expect(() => sorted([2, 1, 3], growable: true).add(4), returnsNormally);
      expect(() => sorted([2, 1, 3], growable: false).add(4), throws);
    });

    test('should use `compare` to compare items', () {
      expect(sorted([2, 1, 3], compare: (a, b) => b.compareTo(a)), [3, 2, 1]);
    });

  });

}
