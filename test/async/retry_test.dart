// Copyright 2016 Google Inc. All Rights Reserved.
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

library quiver.async.retry_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:quiver/async.dart';

void main() {
  group('retry', () {
    test('should run more than once on exception', () async {
      var runCount = 0;
      var task = () async {
        runCount++;
        if (runCount < 2) {
          throw '';
        }
      };
      await retry(task, interval: const Duration(milliseconds: 1));
      expect(runCount, 2);
    });

    test('should return the result of the task', () async {
      var task = () async => 'result';
      expect(await retry(task), 'result');
    });

    test('should rethrow the actual exception after timeout', () async {
      var runCount = 0;
      var task = () async {
        runCount++;
        if (runCount < 2) throw 'error';
        return new Completer().future;
      };
      expect(
          retry(task,
              interval: const Duration(milliseconds: 1),
              timeout: const Duration(milliseconds: 100)),
          throwsA(equals('error')));
    });

    test('should timeout long tasks', () async {
      var task = () => new Completer().future;

      expect(retry(task, timeout: const Duration(milliseconds: 100)),
          throwsA(new isInstanceOf<TimeoutException>()));
    });
  });
}
