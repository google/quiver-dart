library quiver.iterables.avg_test;

import 'package:test/test.dart';
import 'package:quiver/iterables.dart';

void main() {
  group('avg', () {
    test('should return the average of elements', () {
      expect(avg([2, 5, 1, 4]), 3);
    });

    test('should return null if the iterable is empty', () {
      expect(avg<int>([]), null);
    });
  });
}
