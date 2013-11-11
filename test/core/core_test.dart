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

library quiver.core_test;

import 'package:quiver/core.dart';
import 'package:unittest/matcher.dart';
import 'package:unittest/unittest.dart';

main() {
  group('firstNonNull', () {

    test("should return the first argument if it isn't null", () {
        expect(firstNonNull(1, 2), 1);
    });

    test("should return the second argument if it isn't null", () {
        expect(firstNonNull(null, 2), 2);
    });

    test("should return the third argument if it isn't null", () {
        expect(firstNonNull(null, null, 3), 3);
    });

    test("should return the fourth argument if it isn't null", () {
        expect(firstNonNull(null, null, null, 4), 4);
    });

    test("should throw if all argumentsare null", () {
        expect(() => firstNonNull(null, null, null, null), throwsArgumentError);
    });

  });
}
