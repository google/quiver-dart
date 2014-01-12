library quiver.iterable.slice_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/iterables.dart';

main() {
  group("slice", () {
    test("should create an empty iterator is stop is 0", () {
      expect(slice([1,2,3,4,5], 0), []);
    });

    test("should return stop number of elements, starting at 0", () {
      expect(slice([0,1,2,3,4,5,6,7,8,9], 5), [0,1,2,3,4]);
    });

    test("should start sequence at start_or_stop", () {
      expect(slice([0,1,2,3,4,5,6,7,8,9], 5, 11),
             [5,6,7,8,9]);
      expect(slice([0,1,2,3,4,5,6,7,8,9], 5, 9),
             [5,6,7,8]);
    });

    test("slice should retrieve elements seperated by step", () {
      expect(slice([0,1,2,3,4,5,6,7,8,9], 0,10,2),
             [0,2,4,6,8]);
      expect(slice([0,1,2,3,4,5,6,7,8,9], 0,10,3),
             [0,3,6,9]);
    });

    test("slice should throw if start < stop", () {
      expect(() => slice([], 8, 5), throws);
    });

    test("slice should throw with a bad step", () {
      expect(() => slice([], 1, 4, -1), throws);
    });
  });
}