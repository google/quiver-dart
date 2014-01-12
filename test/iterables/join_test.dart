library quiver.iterables.join_tests;

import 'package:unittest/unittest.dart';
import 'package:quiver/core.dart';
import 'package:quiver/iterables.dart';

main() {
  testGroupJoin();
  testInnerJoin();
}

testGroupJoin() {
  group("groupjoin", () {
    test("should be empty if the inner iterable is empty", () {
      expect(groupJoin([], [1,2,3,4,5]), []);
    });

    test("should contain a group for each element of the inner iterable", () {
      expect(groupJoin([1,2,3,4,5], []).map((grp) => grp.key),
             [1,2,3,4,5]);
      expect(groupJoin([1,2,3,4,5], []).expand((grp) => grp.values),
             isEmpty);
    });

    test("should default the inner key to the identity function", () {
      expect(groupJoin([1,2,3,4,5], [2,4,6,8,8], outerKey: (x) => x ~/ 2),
             [ new Group(1, [2]),
               new Group(2, [4]),
               new Group(3, [6]),
               new Group(4, [8,8]),
               new Group(5, [])
             ]);
    });

    test("should default the outer key to the identity function", () {
      expect(groupJoin([1,2,3,4,5], [2,4,6,8,8], innerKey: (x) => x * 2),
            [ new Group(1, [2]),
              new Group(2, [4]),
              new Group(3, [6]),
              new Group(4, [8,8]),
              new Group(5, [])
            ]);
    });

    test("should group by the values of the inner and outer keys", () {
      expect(groupJoin([1, 2, 3, 4, 5, 6], [ [1,2], [1,3], [1,4], [1,5], [1,6],
                                             [2,3], [2,4], [2,5], [2,6],
                                             [3,4], [3,5], [3,6],
                                             [4,5], [4,6],
                                             [5,6]],
                       innerKey: (x) => x * 2,
                       outerKey: (x) => x[0] + x[1]),
             [ new Group(1, []),
               new Group(2, [[1,3]]),
               new Group(3, [[1,5], [2,4]]),
               new Group(4, [[2,6], [3,5]]),
               new Group(5, [[4,6]]),
               new Group(6, [])
             ]);
    });
  });
}

testInnerJoin() {
  group("innerjoin", () {
    test("should skip values which don't agree on the keys", () {
      expect(innerJoin([1,2,3,4,5], [2,3,4,5,6]),
             [new InnerJoinResult(2,2),
              new InnerJoinResult(3,3),
              new InnerJoinResult(4,4),
              new InnerJoinResult(5,5)
             ]);
    });
  });
}

testOuterJoin() {
  group("outerjoin", () {
    test("should contain absent an absent value for an inner element with no matching outer elements"
         "or if the inner and outer key functions return null", () {
      expect(leftOuterJoin([1,2,3,4,null], [2,3,4,null,6]),
             [ new OuterJoinResult(1, new Optional.absent()),
               new OuterJoinResult(2, new Optional.of(2)),
               new OuterJoinResult(3, new Optional.of(3)),
               new OuterJoinResult(4, new Optional.of(4)),
               new OuterJoinResult(null, new Optional.absent())
             ]);
    });
  });
}