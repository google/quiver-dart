// Copyright 2018 Google Inc. All Rights Reserved.
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

library quiver.iterables.map;

import 'package:quiver/iterables.dart';
import 'package:test/test.dart';

main() {
  group("iterable map utils", () {
    test("mapWhen should modify elements properly", () {
      expect(mapWhen<int>([0, 1, 2, 3, 4], (i) => i.isEven, (o) => o * o),
          [0, 1, 4, 3, 16]);
    });

    test("mapIndexed should insert indexes and modify list properly", () {
      expect(mapIndexed([3, 2, 1, 0], (index, item) => index * item),
          [0, 2, 2, 0]);
    });

    test("annotate should produce corrent iterable modification", () {
      expect(annotate([2, 3], (item) => item * item), [
        {2: 4},
        {3: 9}
      ]);
    });

    test("mapcat should proper concatenation result", () {
      expect(mapcat([1, 2, 3, 4], (item) => item * item),
          [1, 1, 2, 4, 3, 9, 4, 16]);
    });

    test("items should be correclty selected", () {
      expect(selectByIndex([1, 2, 3, 4], [0, 3]), [1, 4]);
    });

    test("isPrefix should be true", () {
      expect(isPrefix([1, 2], [1, 2, 3, 4]), true);
    });

    test("isSuffix should be false", () {
      expect(isSuffix([1, 0], [4, 3, 2, 1, 0]), true);
    });

    test("spliAt should return corrent result", () {
      expect(splitAt([1, 2, 3, 4], 2), [
        [1, 2],
        [3, 4]
      ]);
    });

    test("takeLast should return corrent result", () {
      expect(takeLast([1, 2, 3, 4, 5, 6], 2), [5, 6]);
    });

    test("splitWith should return correct iterable", () {
      expect(splitWith<int>([1, 2, 3, 4, 5, 6], (item) => item.isEven), [
        [2, 4, 6],
        [1, 3, 5]
      ]);
    });
  });
}
