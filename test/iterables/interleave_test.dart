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

library quiver.iterables.merge_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/iterables.dart';

main() {
  group('interleave', () {
    test("should interleave no iterables into empty iterable", () {
      expect(interleave([]), []);
    });

    test("should interleave iterables with empty iterable into empty iterable", () {
      expect(interleave([[1, 2, 3], []]), []);
      expect(interleave([[1, 2, 3], [], ['a', 'b', 'c']]), []);
      expect(interleave([[], ['a', 'b', 'c']]), []);
    });

    test("should interleave till shortest iterable is exhausted", () {
      expect(interleave([range(1, 100), ['a', 'b', 'c' ]]), [1, 'a', 2, 'b', 3, 'c']);
      expect(interleave([['-'], range(1, 100), ['a', 'b', 'c' ]]), ['-', 1, 'a']);
    });

    test("should interleave single iterable into self", () {
      expect(interleave([[1, 2, 3]]), [1, 2, 3]);
    });

    test("should throw on null elements", () {
      expect(() => interleave([[1, 2, 3], null]).forEach((e) {}), throws);
    });
  });
}
