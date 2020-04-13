library quiver.iterables.sum_test;

import 'package:test/test.dart';
import 'package:quiver/iterables.dart';

void main() {
  group('sum', () {
    test('should return the sum of elements', () {
      expect(sum([2, 5, 1, 4]), 12);
    });

    test('should return null if the iterable is empty', () {
      expect(sum<int>([]), null);
    });
  });
}
