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

library quiver.compare.quantity_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/compare.dart';

main() {

  group('Quantity', () {

    test('should correctly implement comparison operators', () {

      testOperator(op(a, b), bool lt, bool eq, bool gt) {
        boolMatcher(bool v) => v ? isTrue : isFalse;
        var one = new TestQuantity(1);
        expect(op(new TestQuantity(0), one), boolMatcher(lt));
        expect(op(new TestQuantity(1), one), boolMatcher(eq));
        expect(op(new TestQuantity(2), one), boolMatcher(gt));
      }

      testOperator((a, b) => a <  b, true,  false, false);
      testOperator((a, b) => a <= b, true,  true,  false);
      testOperator((a, b) => a == b, false, true,  false);
      testOperator((a, b) => a >= b, false, true,  true);
      testOperator((a, b) => a >  b, false, false, true);

    });

  });
}

class TestQuantity extends Object with Quantity<TestQuantity> {

  final int i;

  TestQuantity(this.i);

  int compareTo(TestQuantity other) => i.compareTo(other.i);
}
