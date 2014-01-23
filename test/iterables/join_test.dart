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
      expect(groupJoin([1,2,3,4,5], []).map((grp) => grp.inner),
             [1,2,3,4,5]);
      expect(groupJoin([1,2,3,4,5], []).expand((grp) => grp.outer),
             isEmpty);
    });

    test("should group according to the result of on", () {
      expect(groupJoin([1,2,3,4,5], [2,4,6,8,8], on: (x,y) => x * 2 == y),
             [ new GroupJoinRow(1, [2]),
               new GroupJoinRow(2, [4]),
               new GroupJoinRow(3, [6]),
               new GroupJoinRow(4, [8,8]),
               new GroupJoinRow(5, [])
             ]);
    });

    test("should group according to the result of on", () {
      expect(groupJoin([1, 2, 3, 4, 5, 6], [ [1,2], [1,3], [1,4], [1,5], [1,6],
                                             [2,3], [2,4], [2,5], [2,6],
                                             [3,4], [3,5], [3,6],
                                             [4,5], [4,6],
                                             [5,6]],
                       on : (x,y) => 2 * x == y[0] + y[1]),
             [ new GroupJoinRow(1, []),
               new GroupJoinRow(2, [[1,3]]),
               new GroupJoinRow(3, [[1,5], [2,4]]),
               new GroupJoinRow(4, [[2,6], [3,5]]),
               new GroupJoinRow(5, [[4,6]]),
               new GroupJoinRow(6, [])
             ]);
    });
  });
}

testInnerJoin() {
  group("innerjoin", () {
    test("should skip values which don't agree on the keys", () {
      expect(innerJoin([1,2,3,4,5], [2,3,4,5,6]),
             [new InnerJoinRow(2,2),
              new InnerJoinRow(3,3),
              new InnerJoinRow(4,4),
              new InnerJoinRow(5,5)
             ]);
    });
  });
}

testOuterJoin() {
  group("outerjoin", () {
    test("should contain absent an absent value for an inner element with no matching outer elements"
         "or if the inner and outer key functions return null", () {
      expect(leftOuterJoin([1,2,3,4,null], [2,3,4,null,6]),
             [ new OuterJoinRow(1, new Optional.absent()),
               new OuterJoinRow(2, new Optional.of(2)),
               new OuterJoinRow(3, new Optional.of(3)),
               new OuterJoinRow(4, new Optional.of(4)),
               new OuterJoinRow(null, new Optional.absent())
             ]);
    });
  });
}