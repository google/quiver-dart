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

library quiver.compare.ordered_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/compare.dart';

main() {

  group('isOrdered', () {

    test('should determine whether iterable is ordered', () {
      expect(isOrdered([]), isTrue);
      expect(isOrdered([1]), isTrue);
      expect(isOrdered([1, 2]), isTrue);
      expect(isOrdered([2, 1]), isFalse);
      expect(isOrdered([1, 1]), isTrue);
    });

    test('should use `compare` to compare items', () {
      c(a, b) => 0;
      expect(isOrdered([2, 1], compare: c), isTrue);
    });

  });

  group('isStrictlyOrdered', () {

    test('should determine whether iterable is strictly ordered', () {
      expect(isStrictlyOrdered([]), isTrue);
      expect(isStrictlyOrdered([1]), isTrue);
      expect(isStrictlyOrdered([1, 2]), isTrue);
      expect(isStrictlyOrdered([2, 1]), isFalse);
      expect(isStrictlyOrdered([1, 1]), isFalse);
    });

    test('should use `compare` to compare items', () {
      c(a, b) => 0;
      expect(isStrictlyOrdered([1, 2], compare: c), isFalse);
    });

  });

}
