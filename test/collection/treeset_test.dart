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

library quiver.collection.treeset_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

main() {
  group("TreeSet", () {
    group("when empty", () {
      TreeSet<num> tree;
      setUp(() { tree = new TreeSet<num>(); });
      test("should actually be empty", () => expect(tree, isEmpty));
      test("should not contain an element",
          () => expect(tree.lookup(0), isNull));
      test("has no element when iterating forward", () {
        var i = tree.iterator;
        expect(i.moveNext(), isFalse, reason: "moveNext reports an element");
        expect(i.current, isNull, reason: "current returns an element");
      });
      test("has no element when iterating backward", () {
        var i = tree.iterator;
        expect(i.movePrevious(), isFalse,
            reason: "movePrevious reports an element");
        expect(i.current, isNull, reason: "current returns an element");
      });
    });

    group("with [10, 20, 15]", () {
      AvlTreeSet<num> tree;
      setUp(() {
        tree = new TreeSet<num>()..addAll([10, 20, 15]);
      });
      test("lookup succeeds for inserted elements", () {
        expect(tree.lookup(10), equals(10), reason: "missing 10");
        expect(tree.lookup(15), equals(15), reason: "missing 15");
        expect(tree.lookup(20), equals(20), reason: "missing 20");
      });
      test("order is correct", () {
        AvlNode ten = tree.getNode(10);
        AvlNode twenty = tree.getNode(20);
        AvlNode fifteen = tree.getNode(15);
        expect(ten.predecessor, isNull, reason: "10 is the smalled element");
        expect(ten.successor, equals(fifteen), reason: "15 should follow 10");
        expect(ten.successor.successor, equals(twenty),
            reason: "20 should follow 10");

        expect(twenty.successor, isNull, reason: "20 is the largest element");
        expect(twenty.predecessor, equals(fifteen), reason: "15 is before 20");
        expect(twenty.predecessor.predecessor, equals(ten),
            reason: "10 is before 15");
      });
    });

    group("with repeated elements", () {
      TreeSet<num> tree;
      setUp(() {
        tree = new TreeSet<num>()
            ..addAll([10, 20, 15, 21, 30, 20]);
      });

      test("only contains subset", () {
        var it = tree.iterator;
        var testList = new List.from([10, 15, 20, 21, 30]);
        while (it.moveNext()) {
          expect(it.current, equals(testList.removeAt(0)));
        }
        expect(testList.length, equals(0), reason: "valid subset seen in tree");
      });
    });

    group("iteration", () {
      TreeSet<num> tree;
      setUp(() {
        tree = new TreeSet<num>()
            ..addAll([10, 20, 15, 21, 30]);
      });

      test("works bidirectionally", () {
        var testList = new List.from([10, 15, 20, 21, 30]);
        var it = tree.iterator;
        while (it.moveNext());
        expect(it.movePrevious(), isTrue,
            reason: "we can backup after walking the entire list");
        expect(it.current, equals(30),
            reason: "the last element is what we expect");
        while (it.movePrevious());
        expect(it.moveNext(), isTrue,
            reason: "we can move next after walking to the front of the set");
        expect(it.current, equals(10),
            reason: "the first element is what we expect");
      });

      group("from", () {
        test("non-inserted midpoint works forward", () {
          var it = tree.fromIterator(19);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.moveNext(), isTrue, reason: "moveNext() from spot works");
          expect(it.current, equals(20));
        });

        test("non-inserted midpoint works for movePrevious()", () {
          var it = tree.fromIterator(19);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.movePrevious(), isTrue,
              reason: "movePrevious() from spot works");
          expect(it.current, equals(15));
        });

        test("non-inserted midpoint works reversed", () {
          var it = tree.fromIterator(19, reversed: true);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.moveNext(), isTrue, reason: "moveNext() from spot works");
          expect(it.current, equals(15));
        });

        test("non-inserted midpoint works reversed, movePrevious()", () {
          var it = tree.fromIterator(19, reversed: true);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.movePrevious(), isTrue,
              reason: "movePrevious() from spot works");
          expect(it.current, equals(20));
        });

        test("inserted midpoint works foreward", () {
          var it = tree.fromIterator(20);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.moveNext(), isTrue, reason: "moveNext() from spot works");
          expect(it.current, equals(20));
        });

        test("inserted midpoint works reversed", () {
          var it = tree.fromIterator(20, reversed: true);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.moveNext(), isTrue, reason: "moveNext() from spot works");
          expect(it.current, equals(20));
        });

        test("after the set", () {
          var it = tree.fromIterator(100);
          expect(it.current, isNull);
          expect(it.moveNext(), isFalse, reason: "not following items");
          expect(it.movePrevious(), isTrue, reason: "backwards movement valid");
          expect(it.current, equals(30));
        });

        test("before the set", () {
          var it = tree.fromIterator(0);
          expect(it.current, isNull);
          expect(it.movePrevious(), isFalse, reason: "not previous items");
          expect(it.moveNext(), isTrue, reason: "forwards movement valid");
          expect(it.current, equals(10));
        });

        test("inserted midpoint, non-inclusive, works foreward", () {
          var it = tree.fromIterator(20, inclusive: false);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.moveNext(), isTrue, reason: "moveNext() from spot works");
          expect(it.current, equals(21));
        });

        test("inserted endpoint, non-inclusive, works foreward", () {
          var it = tree.fromIterator(30, inclusive: false);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.moveNext(), isFalse, reason: "moveNext() from spot works");

          it = tree.fromIterator(10, inclusive: false);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.moveNext(), isTrue, reason: "moveNext() from spot works");
          expect(it.current, equals(15),
              reason: "non-inclusive start should be 15");
        });

        test("inserted endpoint, non-inclusive, works backward", () {
          var it = tree.fromIterator(10, inclusive: false);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.movePrevious(), isFalse,
              reason: "movePrevious() from spot is null");

          it = tree.fromIterator(30, inclusive: false);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.movePrevious(), isTrue, reason: "moveNext() from spot works");
          expect(it.current, equals(21));
        });

        test("inserted midpoint, non-inclusive and reversed, works foreward", () {
          var it = tree.fromIterator(20, inclusive: false, reversed: true);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.moveNext(), isTrue, reason: "moveNext() from spot works");
          expect(it.current, equals(15));
        });

        test("inserted endpoint, non-inclusive and reversed, works foreward", () {
          var it = tree.fromIterator(30, inclusive: false, reversed: true);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.moveNext(), isTrue, reason: "moveNext() from spot works");
          expect(it.current, equals(21));

          it = tree.fromIterator(10, inclusive: false, reversed: true);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.moveNext(), isFalse, reason: "moveNext() works");
        });

        test("inserted endpoint, non-inclusive and reversed, works backward", () {
          var it = tree.fromIterator(10, inclusive: false, reversed: true);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.movePrevious(), isTrue, reason: "moveNext() from spot works");
          expect(it.current, equals(15));

          it = tree.fromIterator(30, inclusive: false, reversed: true);
          expect(it.current, isNull, reason: "iteration starts with null");
          expect(it.movePrevious(), isFalse, reason: "moveNext() from spot works");
        });
      });

      group("fails", () {
        var it;
        setUp(() => it = tree.iterator);

        test("after tree is cleared", () {
          tree.clear();
          var error;
          try { it.moveNext(); } catch (e) {
            error = e;
          }
          expect(error, isConcurrentModificationError);
        });

        test("after inserting an element", () {
          tree.add(101);
          var error;
          try { it.moveNext(); } catch (e) {
            error = e;
          }
          expect(error, isConcurrentModificationError);
        });

        test("after removing an element", () {
          tree.remove(10);
          var error;
          try { it.moveNext(); } catch (e) {
            error = e;
          }
          expect(error, isConcurrentModificationError);
        });
      });

      group("still works", () {
        var it;
        setUp(() => it = tree.iterator);

        test("when removing non-existing element", () {
          tree.remove(42);
          var error;
          try { it.moveNext(); } catch (e) {
            error = e;
          }
          expect(error, isNull, reason: "set was not modified");
        });
        test("when adding an already existing element", () {
          tree.add(10);
          var error;
          try { it.moveNext(); } catch (e) {
            error = e;
          }
          expect(error, isNull, reason: "set was not modified");
        });
      });
    });

    group("set math", () {
      /// NOTE: set math with sorted sets should have a performance benifit,
      /// we do not check the performance, only that the resulting math
      /// is equivilant to non-sorted sets.

      TreeSet<num> tree;
      List<num> expectedUnion;
      List<num> expectedIntersection;
      List<num> expectedDifference;
      Set<num> nonSortedTestSet;
      TreeSet<num> sortedTestSet;

      setUp(() {
        tree = new TreeSet()..addAll([10, 20, 15, 21, 30, 20]);
        expectedUnion = [10, 15, 18, 20, 21, 22, 30];
        expectedIntersection = [10, 15];
        expectedDifference= [20, 21, 30];
        nonSortedTestSet = new Set.from([10, 18, 22, 15]);
        sortedTestSet = new TreeSet()..addAll(nonSortedTestSet);
      });

      test("union with non sorted set", () =>
        expect(tree.union(nonSortedTestSet).toList(), equals(expectedUnion))
      );
      test("union with sorted set", () =>
        expect(tree.union(sortedTestSet).toList(), equals(expectedUnion))
      );
      test("intersection with non sorted set", () =>
        expect(tree.intersection(nonSortedTestSet).toList(),
            equals(expectedIntersection))
      );
      test("intersection with sorted set", () =>
        expect(tree.intersection(sortedTestSet).toList(),
            equals(expectedIntersection))
      );
      test("difference with non sorted set", () =>
        expect(tree.difference(nonSortedTestSet).toList(),
            equals(expectedDifference))
      );
      test("difference with sorted set", () =>
        expect(tree.difference(sortedTestSet).toList(),
            equals(expectedDifference))
      );
    });

    group("AVL implementaiton", () {
      /// NOTE: This is implementation specific testing for coverage.
      /// Users do not have access to [AvlNode] or [AvlTreeSet]
      test("RightLeftRotation", () {
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
        expect(ten.balance, equals(0));

        expect(twenty.parent, equals(fifteen));
        expect(twenty.left, equals(null));
        expect(twenty.right, equals(null));
        expect(twenty.balance, equals(0));

        expect(fifteen.parent, equals(null));
        expect(fifteen.left, equals(ten));
        expect(fifteen.right, equals(twenty));
        expect(fifteen.balance, equals(0));
      });
      test("LeftRightRotation", () {
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
        expect(thirty.balance, equals(0));

        expect(ten.parent, equals(twenty));
        expect(ten.left, equals(null));
        expect(ten.right, equals(null));
        expect(ten.balance, equals(0));

        expect(twenty.parent, equals(null));
        expect(twenty.left, equals(ten));
        expect(twenty.right, equals(thirty));
        expect(twenty.balance, equals(0));
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
        expect(one.balance, equals(0));

        expect(three.parent, equals(two));
        expect(three.left, equals(null));
        expect(three.right, equals(null));
        expect(three.balance, equals(0));

        expect(two.parent, equals(null));
        expect(two.left, equals(one));
        expect(two.right, equals(three));
        expect(two.balance, equals(0));
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
        expect(one.balance, equals(0));

        expect(three.parent, equals(two));
        expect(three.left, equals(null));
        expect(three.right, equals(null));
        expect(three.balance, equals(0));

        expect(two.parent, equals(null));
        expect(two.left, equals(one));
        expect(two.right, equals(three));
        expect(two.balance, equals(0));
      });
    });


    group("nearest search", () {
      TreeSet<num> tree;
      setUp(() {
        tree = new TreeSet<num>(comparator:
          (num left, num right) {
            return left - right;
          })..addAll([300,200,100]);
      });

      test("NEAREST is sane", () {
        var val = tree.nearest(199);
        expect(val, equals(200), reason: "199 is closer to 200");
        val = tree.nearest(201);
        expect(val, equals(200), reason: "201 is 200");
        val = tree.nearest(150);
        expect(val, equals(100), reason: "150 defaults to lower 100");
      });

      test("LESS_THAN is sane", () {
        var val = tree.nearest(199, nearestOption: TreeSearch.LESS_THAN);
        expect(val, equals(100), reason: "199 rounds down to 100");
      });

      test("GREATER_THAN is sane", () {
        var val = tree.nearest(101, nearestOption: TreeSearch.GREATER_THAN);
        expect(val, equals(200), reason: "101 rounds up to 200");
      });
    });
  });
}