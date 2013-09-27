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

library quiver.collection.listed_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

main() {
  group('Listed', () {
    test('should be instantiable as Listed<String>', () {
      var listed = new Listed<String>(["1", "2", "2", "3"]);

      expect(listed.contains("2"), isTrue);
      expect(listed.length, equals(4));
    });

    test('should be instantiable as Listed<Object>', () {
      var listed = new Listed<Object>(["1", 2]);

      expect(listed.contains("1"), isTrue);
      expect(listed.contains(2), isTrue);
    });

    test('should be instantiable via checkedCast', () {
      expect(() => new Listed<String>.checkedCast([1, 2]), throws);
      expect(
          new Listed<String>.checkedCast(["1", "2"])
              == new Listed<String>.checkedCast(["1", "2"]),
          isTrue);
    });

    test('should not support add', () {
      var listed = new Listed<String>(["1", "2", "2", "3"]);

      expect(() => listed.add('foo'), throws);
    });

    test('should implement +', () {
      var listed1 = new Listed<String>(["1", "2", "2", "3"]);
      var listed2 = listed1 + "4";
      var listed3 = listed2 + ["5", "6"];
      var listed4 = listed3 + new Listed<String>(["7", "8"]);

      expect(listed3 == new Listed<String>(["1", "2", "2", "3", "4", "5", "6"]), isTrue);
    });

    test('should implement +=', () {
      var listed1 = new Listed<String>(["1", "2", "2", "3"]);
      listed1 += "4";
      listed1 += ["5", "6"];
      listed1 += new Listed<String>(["7", "8"]);

      expect(listed1 == new Listed<String>(["1", "2", "2", "3", "4", "5", "6", "7", "8"]), isTrue);
    });

    test('should throw on wrong type for +', () {
      var listed1 = new Listed<String>(["1", "2", "2", "3"]);
      expect(() => listed1 + 5, throws);
      expect(() => listed1 + [5], throws);
      expect(() => listed1 + new Listed<int>([5]), throws);
    });

    test('should support replace', () {
      var listed1 = new Listed<String>(["1", "2", "2", "3"]);
      var listed2 = listed1.replace("2", "7");
      var listed3 = new Listed<String>(["1", "7", "2", "3"]);
      expect(listed2 != listed1, isTrue);
      expect(listed2 == listed3, isTrue);
      expect(() => listed1.replace("12", "7"), throws);
    });

    test('should implement deep equals', () {
      var listed1 = new Listed<String>(["1", "2", "2", "3"]);
      var listed2 = new Listed<String>(["1", "2", "2", "3"]);
      var listed3 = new Listed<String>(["1", "2", "4", "3"]);

      expect(listed1 == listed2, isTrue);
      expect(listed1 == listed3, isFalse);
    });

    test('should implement deep hashCode', () {
      var listed1 = new Listed<String>(["1", "2", "2", "3"]);
      var listed2 = new Listed<String>(["1", "2", "2", "3"]);
      var listed3 = new Listed<String>(["1", "2", "4", "3"]);

      expect(listed1.hashCode == listed2.hashCode, isTrue);
      expect(listed1.hashCode == listed3.hashCode, isFalse);
    });
  });
}
