// Copyright 2014 Google Inc. All Rights Reserved.
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

library quiver.testing.matchers.all_tests;

import 'package:quiver/testing/matchers.dart';
import 'package:unittest/unittest.dart';

main() {
  group('isAssignableTo', () {
    test('should throws on well-formed types', () {
      expect(() {
        expect(3, new isAssignableTo<double>());
      }, throws);
    });
    test('should throws on malformed types', () {
      expect(() {
        expect(3, new isAssignableTo<ThisClassDoesNotExist>());
      }, throws);
    });
    test('should throws on Object', () {
      expect(() {
        expect(3, new isAssignableTo<Object>());
      }, throws);
    });
    test('should throws on dynamic', () {
      expect(() {
        expect(3, new isAssignableTo<dynamic>());
      }, throws);
    });
    test('should succeed', () {
      expect(3, new isAssignableTo<int>());
    });
  });
}
