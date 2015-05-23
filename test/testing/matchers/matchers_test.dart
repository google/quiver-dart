// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library quiver.testing.matchers;

import 'package:quiver/testing/matchers.dart';
import 'package:test/test.dart';

main() {
  group('isBefore', () {
    test('correctly identifies when a is before b', () {
      var a = new DateTime.now();
      var b = new DateTime.now().add(new Duration(seconds: 1));
      expect(a, isBefore(b));
    });

    test('throws exception when a is not before b', () {
      var a = new DateTime.now();
      var b = new DateTime.now().add(new Duration(seconds: 1));
      expect(() => expect(b, isBefore(a)), throws);
    });

    test('throws exception when a is at the same moment as b', () {
      var a = new DateTime.now();
      var b = a;
      expect(() => expect(b, isBefore(a)), throws);
    });
  });

  group('isAfter', () {
    test('correctly identifies when a is after b', () {
      var a = new DateTime.now();
      var b = new DateTime.now().add(new Duration(seconds: 1));
      expect(a, isBefore(b));
    });

    test('throws exception when a is not after b', () {
      var a = new DateTime.now().add(new Duration(seconds: 1));
      var b = new DateTime.now();
      expect(() => expect(b, isAfter(a)), throws);
    });

    test('throws exception when a is at the same moment as b', () {
      var a = new DateTime.now();
      var b = a;
      expect(() => expect(b, isAfter(a)), throws);
    });
  });

  group('isAtTheSameMoment', () {
    test('correctly identifies when a is at the same moment as b', () {
      var a = new DateTime(1942);
      var b = new DateTime(1942);
      expect(a, isTheSameMomentAs(b));
    });

    test('throws exception when a is not at the same moment as b', () {
      var a = new DateTime.now();
      var b = new DateTime.now().add(new Duration(seconds: 1));
      expect(() => expect(b, isTheSameMomentAs(a)), throws);
    });
  });
}
