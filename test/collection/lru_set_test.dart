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

library quiver.collection.lru_map_test;

import 'package:quiver/collection.dart';
import 'package:test/test.dart';

void main() {
  group('LruSet', () {
    /// A set that will be initialize by individual tests.
    LruSet<String> lruSet;

    test('the length property reflects how many elements are in the set', () {
      lruSet = new LruSet();
      expect(lruSet, hasLength(0));

      lruSet.addAll(new Set.from([
        'A',
        'B',
        'C'
      ]));
      expect(lruSet, hasLength(3));
    });

    test('accessing elements causes them to be promoted', () {
      lruSet = new LruSet()..addAll(new Set.from([
        'A',
        'B',
        'C'
      ]));

      expect(lruSet.toList(), ['C', 'B', 'A']);

      lruSet.lookup('B');

      // In a LRU cache, the first element is the one that will be removed if the
      // capacity is reached, so adding elements to the end is considered to be a
      // 'promotion'.
      expect(lruSet.toList(), ['B', 'C', 'A']);
    });

    test('new elements are added at the beginning', () {
      lruSet = new LruSet()..addAll(new Set.from([
        'A',
        'B',
        'C'
      ]));

      lruSet.add('D');
      expect(lruSet.toList(), ['D', 'C', 'B', 'A']);
    });

    test('setting values on existing elements works, and promotes the key', () {
      lruSet = new LruSet()..addAll(new Set.from([
        'A',
        'B',
        'C'
      ]));

      lruSet.add('B');
      expect(lruSet.toList(), ['B', 'C', 'A']);
    });

    test('the least recently used element is evicted when capacity hit', () {
      lruSet = new LruSet(maximumSize: 3)..addAll(new Set.from([
        'A',
        'B',
        'C'
      ]));

      lruSet.add('D');
      expect(lruSet.toList(), ['D', 'C', 'B']);
    });

    test('setting maximum size evicts elements until the size is met', () {
      lruSet = new LruSet(maximumSize: 5)..addAll(new Set.from([
        'A',
        'B',
        'C',
        'D',
        'E'
      ]));

      lruSet.maximumSize = 3;
      expect(lruSet.toList(), ['E', 'D', 'C']);
    });

    test('accessing the iterator does not affect position', () {
      lruSet = new LruSet()..addAll(new Set.from([
        'A',
        'B',
        'C'
      ]));

      expect(lruSet.toList(), ['C', 'B', 'A']);

      Iterator iterator = lruSet.iterator;
      while(iterator.moveNext());

      expect(lruSet.toList(), ['C', 'B', 'A']);
    });

    test('clearing removes all elements', () {
      lruSet = new LruSet()..addAll(new Set.from([
        'A',
        'B',
        'C'
      ]));

      expect(lruSet.isNotEmpty, isTrue);

      lruSet.clear();

      expect(lruSet.isEmpty, isTrue);
    });

    test('`contains` returns true if the element is in the set', () {
      lruSet = new LruSet()..addAll(new Set.from([
        'A',
        'B',
        'C'
      ]));

      expect(lruSet.contains('A'), isTrue);
      expect(lruSet.contains('D'), isFalse);
    });

    test('`forEach` returns all items without modifying order', () {
      final elements = [];

      lruSet = new LruSet()..addAll(new Set.from([
        'A',
        'B',
        'C'
      ]));

      expect(lruSet.toList(), ['C', 'B', 'A']);

      lruSet.forEach((element) {
        elements.add(element);
      });

      expect(elements, ['C', 'B', 'A']);
      expect(lruSet.toList(), ['C', 'B', 'A']);
    });

    group('`remove`', () {
      setUp(() {
        lruSet = new LruSet()..addAll(new Set.from([
          'A',
          'B',
          'C'
        ]));
      });

      test('returns the value associated with a key, if it exists', () {
        expect(lruSet.remove('A'), true);
      });

      test('returns null if the provided element does not exist', () {
        expect(lruSet.remove('D'), false);
      });

      test('can remove the head', () {
        lruSet.remove('C');
        expect(lruSet.toList(), ['B', 'A']);
      });

      test('can remove the tail', () {
        lruSet.remove('A');
        expect(lruSet.toList(), ['C', 'B']);
      });

      test('can remove a middle entry', () {
        lruSet.remove('B');
        expect(lruSet.toList(), ['C', 'A']);
      });
    });

    group('`add`', () {
      setUp(() {
        lruSet = new LruSet()..addAll(new Set.from([
          'A',
          'B',
          'C'
        ]));
      });

      test('adds an item if it does not exist, and moves it to the MRU', () {
        expect(lruSet.add('D'), true);
        expect(lruSet.toList(), ['D', 'C', 'B', 'A']);
      });

      test('does not add an item if it exists, but does promote it to MRU', () {
        expect(lruSet.add('B'), false);
        expect(lruSet.toList(), ['B', 'C', 'A']);
      });

      test('removes the LRU item if `maximumSize` exceeded', () {
        lruSet.maximumSize = 3;
        expect(lruSet.add('D'), true);
        expect(lruSet.toList(), ['D', 'C', 'B']);
      });
    });
  });
}
