library quiver.iterables.sort_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/iterables.dart';


main() {
  group("sort", () {
    test("should sort an empty list", () {
      expect(sort([]), []);
    });

    test("should default to the default comparator", () {
      expect(sort([3,1,2,6,6,3]), [1,2,3,3,6,6]);
    });

    test("should sort items with a custom ordering", () {
      expect(sort([3,1,2,6,6,3], (a,b) => -Comparable.compare(a, b)),
             [6,6,3,3,2,1]);
    });
  });
}