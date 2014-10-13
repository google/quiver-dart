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

library quiver.check_test;

import 'package:quiver/check.dart' as check;
import 'package:matcher/matcher.dart';
import 'package:unittest/unittest.dart';

main() {
  group('argument', () {
    group('success', () {
      test('simple', () => check.argument(true));
      test('null message', () => check.argument(true, message: null));
      test('string message', () =>
          check.argument(true, message: 'foo'));
      test('function message', () =>
          check.argument(true, message: () => fail("Shouldn't be called")));
    });

    group('failure', () {
      argumentShouldFail(Function f, [String expectedMessage]) {
        try {
          f();
          fail('Should have thrown an ArgumentError');
        } catch (e) {
          expect(e, isArgumentError);
          expect(e.message, expectedMessage);
        }
      }

      test('no message', () =>
          argumentShouldFail(() => check.argument(false)));

      test('failure and simple string message', () =>
        argumentShouldFail(() =>
            check.argument(false, message: 'message'), 'message'));

      test('failure and null message', () =>
        argumentShouldFail(() => check.argument(false, message: null)));
      test('failure and object as message', () =>
        argumentShouldFail(() => check.argument(false, message: 5),
            '5'));
      test('failure and message closure returns object', () =>
        argumentShouldFail(() => check.argument(false, message: () => 5),
            '5'));

      test('failure and message function', () {
        int five = 5;
        argumentShouldFail(() =>
            check.argument(false, message: () => 'I ate $five pies'),
                'I ate 5 pies');
      });
    });
  });

  group('state', () {
    group('success', () {
      test('simple', () => check.state(true));
      test('null message', () => check.state(true, message: null));
      test('string message', () =>
          check.state(true, message: 'foo'));
      test('function message', () =>
          check.state(true, message: () => fail("Shouldn't be called")));
    });

    group('failure', () {
      stateShouldFail(Function f, [String expectedMessage]) {
        if (expectedMessage == null) expectedMessage = 'failed precondition';
        try {
          f();
          fail('Should have thrown a StateError');
        } catch (e) {
          expect(e, isStateError);
          expect(e.message, expectedMessage);
        }
      }

      test('no message', () => stateShouldFail(() => check.state(false)));

      test('failure and simple string message', () =>
        stateShouldFail(
            () => check.state(false, message: 'message'), 'message'));

      test('failure and null message', () =>
        stateShouldFail(() => check.state(false, message: null)));
      test('message closure returns null', () => stateShouldFail(() =>
          check.state(false, message: () => null)));

      test('failure and message function', () {
        int five = 5;
        stateShouldFail(() =>
            check.state(false, message: () => 'I ate $five pies'),
                'I ate 5 pies');
      });
    });
  });

  group('notNull', () {
    group('success', () {
      test('simple', () => expect(check.notNull(''), ''));
      test('string message', () =>
          expect(check.notNull(5, message: 'foo'), 5));
      test('function message', () =>
          expect(check.notNull(true, message: () => fail("Shouldn't be called")),
              true));
    });

    group('failure', () {
      notNullShouldFail(Function f, [String expectedMessage]) {
        if (expectedMessage == null) expectedMessage = 'null pointer';
        try {
          f();
          fail('Should have thrown an ArgumentError');
        } catch (e) {
          expect(e, isArgumentError);
          expect(e.message, expectedMessage);
        }
      }

      test('no message', () =>
          notNullShouldFail(() => check.notNull(null)));

      test('simple failure message', () => notNullShouldFail(() =>
          check.notNull(null, message: 'message'), 'message'));

      test('null message', () => notNullShouldFail(() =>
          check.notNull(null, message: null)));

      test('message closure returns null', () => notNullShouldFail(
          () => check.notNull(null, message: () => null)));

      test('failure and message function', () {
        int five = 5;
        notNullShouldFail(() =>
            check.notNull(null, message: () => 'I ate $five pies'),
                'I ate 5 pies');
      });
    });
  });

  group('listIndex', () {
    test('success', () {
      check.listIndex(0, 1);
      check.listIndex(0, 1, message: () => fail("shouldn't be called"));
      check.listIndex(0, 2);
      check.listIndex(0, 2, message: () => fail("shouldn't be called"));
      check.listIndex(1, 2);
      check.listIndex(1, 2, message: () => fail("shouldn't be called"));
    });

    group('failure', () {
      listIndexShouldFail(
          int index, int size, [message, String expectedMessage]) {
        try {
          check.listIndex(index, size, message: message);
          fail('Should have thrown a RangeError');
        } catch (e) {
          expect(e, isRangeError);
          expect(e.message, expectedMessage == null
              ? 'index $index not valid for list of size $size'
              : expectedMessage);
        }
      }
      test('negative size', () => listIndexShouldFail(0, -1));
      test('negative index', () => listIndexShouldFail(-1, 1));
      test('index too high', () => listIndexShouldFail(1, 1));
      test('zero size', () => listIndexShouldFail(0, 0));

      test('with failure message', () =>
          listIndexShouldFail(1, 1, 'foo', 'foo'));
      test('with failure message function', () {
        int five = 5;
        listIndexShouldFail(
            1, 1, () => 'I ate $five pies', 'I ate 5 pies');
      });
    });
  });
}
