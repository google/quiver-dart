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
  group('listsEqual', () {
    test('return true for equal lists', () {
      expect(listsEqual(null, null), isTrue);
      expect(listsEqual([], []), isTrue);
      expect(listsEqual([1], [1]), isTrue);
      expect(listsEqual(['a', 'b'], ['a', 'b']), isTrue);
    });

    test('return false for non-equal lists', () {
      expect(listsEqual(null, []), isFalse);
      expect(listsEqual([], null), isFalse);
      expect(listsEqual([1], [2]), isFalse);
      expect(listsEqual([1], []), isFalse);
      expect(listsEqual([], [1]), isFalse);
    });
  });

  group('listMap', () {
    test('return true for equal maps', () {
      expect(mapsEqual(null, null), isTrue);
      expect(mapsEqual({}, {}), isTrue);
      expect(mapsEqual({'a': 1}, {'a': 1}), isTrue);
    });

    test('return false for non-equal maps', () {
      expect(mapsEqual(null, {}), isFalse);
      expect(mapsEqual({}, null), isFalse);
      expect(mapsEqual({'a': 1}, {'a': 2}), isFalse);
      expect(mapsEqual({'a': 1}, {'b': 1}), isFalse);
      expect(mapsEqual({'a': 1}, {'a': 1, 'b': 2}), isFalse);
      expect(mapsEqual({'a': 1, 'b': 2}, {'a': 1}), isFalse);
    });
  });
  group("TreeSet", () {
    test("Empty", () {
      TreeSet<num> tree = new TreeSet<num>();
      Iterator it = tree.iterator;
      expect(it.moveNext(), isFalse);
      expect(it.current, isNull);
      expect(it.moveNext(), isFalse);
      expect(it.current, isNull);

      for (var item in tree) {
        fail("this should not happend");
      }

      expect(tree.lookup(0), isNull);
    });

    test("Lookup", () {
      AvlTreeSet<num> tree = new TreeSet<num>();
      tree.addAll([10, 20, 15]);
      expect(tree.lookup(10), equals(10));
      expect(tree.lookup(15), equals(15));
      expect(tree.lookup(20), equals(20));
    });

    test("Order", () {
      AvlTreeSet<num> tree = new TreeSet<num>();
      tree.add(10);
      tree.add(20);
      tree.add(15);

      AvlNode ten = tree.getNode(10);
      AvlNode twenty = tree.getNode(20);
      AvlNode fifteen = tree.getNode(15);

      expect(ten.predecessor, isNull);
      expect(ten.successor, equals(fifteen));
      expect(ten.successor.successor, equals(twenty));

      expect(twenty.successor, isNull);
      expect(twenty.predecessor, equals(fifteen));
      expect(twenty.predecessor.predecessor, equals(ten));
    });

    test("Iterator", () {
      AvlTreeSet<num> tree = new TreeSet<num>();
      List<num> expected = [10, 15, 20, 21, 30];
      tree.addAll([10, 20, 15, 21, 30, 20]);

      var testList = new List.from(expected);
      var it = tree.reversed;
      while (it.moveNext()) {
        expect(it.current, equals(testList.removeLast()));
      }
      expect(testList.length, equals(0));
      testList = new List.from(expected);
      it = tree.iterator;
      while (it.moveNext()) {
        expect(it.current, equals(testList.removeAt(0)));
      }
      expect(testList.length, equals(0));
    });

    test("Set Math", () {
      AvlTreeSet<num> tree = new TreeSet<num>();
      tree.addAll([10, 20, 15, 21, 30, 20]);
      Set<num> testSet = new Set.from([10, 15, 18, 22]);
      List<num> expectedUnion = [10, 15, 18, 20, 21, 22, 30];
      List<num> expectedIntersection = [10, 15];
      List<num> expectedDifference= [20, 21, 30];

      expect(tree.union(testSet).toList(), equals(expectedUnion));
      expect(tree.intersection(testSet).toList(), equals(expectedIntersection));
      expect(tree.difference(testSet).toList(), equals(expectedDifference));
    });

    test("AVL-RightLeftRotation", () {
      AvlTreeSet<num> tree = new TreeSet<num>();
      tree.add(10);
      tree.add(20);
      tree.add(15);

      AvlNode ten = tree.getNode(10);
      AvlNode twenty = tree.getNode(20);
      AvlNode fifteen = tree.getNode(15);

      expect(ten.parent, equals(fifteen));
      expect(ten.left, equals(null));
      expect(ten.right, equals(null));
      expect(ten.balanceFactor, equals(0));

      expect(twenty.parent, equals(fifteen));
      expect(twenty.left, equals(null));
      expect(twenty.right, equals(null));
      expect(twenty.balanceFactor, equals(0));

      expect(fifteen.parent, equals(null));
      expect(fifteen.left, equals(ten));
      expect(fifteen.right, equals(twenty));
      expect(fifteen.balanceFactor, equals(0));
    });

    test("AVL-LeftRightRotation", () {
      AvlTreeSet<num> tree = new TreeSet<num>();
      tree.add(30);
      tree.add(10);
      tree.add(20);

      AvlNode thirty = tree.getNode(30);
      AvlNode ten = tree.getNode(10);
      AvlNode twenty = tree.getNode(20);

      expect(thirty.parent, equals(twenty));
      expect(thirty.left, equals(null));
      expect(thirty.right, equals(null));
      expect(thirty.balanceFactor, equals(0));

      expect(ten.parent, equals(twenty));
      expect(ten.left, equals(null));
      expect(ten.right, equals(null));
      expect(ten.balanceFactor, equals(0));

      expect(twenty.parent, equals(null));
      expect(twenty.left, equals(ten));
      expect(twenty.right, equals(thirty));
      expect(twenty.balanceFactor, equals(0));
    });

    test("AVL-LeftRotation", () {
      AvlTreeSet<num> tree = new TreeSet<num>();
      tree.add(1);
      tree.add(2);
      tree.add(3);

      AvlNode one = tree.getNode(1);
      AvlNode two = tree.getNode(2);
      AvlNode three = tree.getNode(3);

      expect(one.parent, equals(two));
      expect(one.left, equals(null));
      expect(one.right, equals(null));
      expect(one.balanceFactor, equals(0));

      expect(three.parent, equals(two));
      expect(three.left, equals(null));
      expect(three.right, equals(null));
      expect(three.balanceFactor, equals(0));

      expect(two.parent, equals(null));
      expect(two.left, equals(one));
      expect(two.right, equals(three));
      expect(two.balanceFactor, equals(0));
    });

    test("AVL-RightRotation", () {
      AvlTreeSet<num> tree = new TreeSet<num>();
      tree.add(3);
      tree.add(2);
      tree.add(1);

      AvlNode one = tree.getNode(1);
      AvlNode two = tree.getNode(2);
      AvlNode three = tree.getNode(3);

      expect(one.parent, equals(two));
      expect(one.left, equals(null));
      expect(one.right, equals(null));
      expect(one.balanceFactor, equals(0));

      expect(three.parent, equals(two));
      expect(three.left, equals(null));
      expect(three.right, equals(null));
      expect(three.balanceFactor, equals(0));

      expect(two.parent, equals(null));
      expect(two.left, equals(one));
      expect(two.right, equals(three));
      expect(two.balanceFactor, equals(0));
    });

    test("NearestSearch", () {
      TreeSet<num> tree = new TreeSet<num>(comparator:
          (num left, num right) {
            return left - right;
          });
      tree.add(300);
      tree.add(200);
      tree.add(100);

      var val = tree.nearest(199);
      expect(val, equals(200));
      val = tree.nearest(201);
      expect(val, equals(200));
      val = tree.nearest(150);
      expect(val, equals(100));

      val = tree.nearest(199,
          nearestOption: TreeSearch.LESS_THAN);
      expect(val, equals(100));

      val = tree.nearest(101,
          nearestOption: TreeSearch.GREATER_THAN);
      expect(val, equals(200));
    });

    test("Iterator - from", () {
      AvlTreeSet<num> tree = new TreeSet<num>();
      tree.addAll([10, 15, 20, 21, 30]);

      var testList = new List.from([20, 21, 30]);
      var it = tree.from(19);
      expect(it.current, isNull);
      while (it.moveNext()) {
        expect(it.current, equals(testList.removeAt(0)));
      }
      expect(it.current, isNull);
      expect(testList.length, equals(0));
      testList = new List.from([20, 15, 10]);
      it = tree.from(20, reversed: true);
      expect(it.current, isNull);
      while (it.moveNext()) {
        expect(it.current, equals(testList.removeAt(0)));
      }
      expect(it.current, isNull);
      expect(testList.length, equals(0));

      it = tree.from(100);
      expect(it.current, isNull);
      it.moveNext();
      expect(it.current, isNull);

      it = tree.from(0, reversed: true);
      expect(it.current, isNull);
      it.moveNext();
      expect(it.current, isNull);
    });
  });
}
