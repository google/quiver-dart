library quiver.iterables.groupby_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/iterables.dart';

main() {
  group('groupBy', () {
    test("should ge empty given an empty iterable", () {
      expect(groupBy([]), []);
    });
    test("should group by identity if no key function is provided", () {
      expect(groupBy([1,2,2,4,4,6,6,6]),
             [ new Group(1, [1]),
               new Group(2, [2,2]),
               new Group(4, [4,4]),
               new Group(6, [6,6,6])
             ]);
    });
    test("should group values according to the key function", () {
      expect(groupBy(count().take(500), key: (x) => x % 2 == 0),
             [ new Group(0, range(0, 500, 2)),
               new Group(1, range(1, 500, 2))
             ]);
    });
  });
}

