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

library quiver.collection.setted_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

main() {
  group('Setted', () {
    test('should be instantiable from a List', () {
      Setted<String> setted = new Setted<String>(["1", "2", "2", "3"]);

      expect(setted.contains("2"), isTrue);
      expect(setted.length, equals(3));
    });

    test('should be instantiable via checkedCast', () {
      expect(() => new Setted<String>.checkedCast([1, 2]), throws);
      expect(
          new Setted<String>.checkedCast(["1", "2"])
              == new Setted<String>(["1", "2"]),
          isTrue);
    });

    test('should implement +', () {
      var setted1 = new Setted<String>(["1", "2", "2", "3"]);
      var setted2 = setted1 + "4";
      var setted3 = setted2 + ["5", "6"];
      var setted4 = setted3 + new Setted<String>(["7", "8"]);

      expect(setted3 == new Setted<String>(["1", "2", "2", "3", "4", "5", "6"]), isTrue);
    });

    test('should implement +=', () {
      var setted1 = new Setted<String>(["1", "2", "2", "3"]);
      setted1 += "4";
      setted1 += ["5", "6"];
      setted1 += new Setted<String>(["7", "8"]);

      expect(setted1 == new Setted<String>(["1", "2", "2", "3", "4", "5", "6", "7", "8"]), isTrue);
    });

    test('should throw on wrong type for +', () {
      var setted1 = new Setted<String>(["1", "2", "2", "3"]);
      expect(() => setted1 + 5, throws);
      expect(() => setted1 + [5], throws);
      expect(() => setted1 + new Setted<int>([5]), throws);
    });

    test('should implement deep equals', () {
      var setted1 = new Setted<String>(["1", "2", "3"]);
      var setted2 = new Setted<String>(["3", "2", "1"]);
      var setted3 = new Setted<String>(["7", "2", "3"]);

      expect(setted1 == setted2, isTrue);
      expect(setted1 == setted3, isFalse);
    });

    test('should impement deep hashCode', () {
      var setted1 = new Setted<String>(["1", "2", "3"]);
      var setted2 = new Setted<String>(["3", "2", "1"]);
      var setted3 = new Setted<String>(["7", "2", "3"]);

      expect(setted1.hashCode == setted2.hashCode, isTrue);
      expect(setted1.hashCode == setted3.hashCode, isFalse);
    });
  });
}
