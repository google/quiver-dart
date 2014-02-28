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

library quiver.async.settle_test;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:quiver/async.dart';

main() {
  group('settle', () {

    test('returns on empty list for empty input', () {
      expect(settle([]), completion([]));
    });

    test('maps a list of future into SettleResults', () {
      return settle([new Future.value('ok'), new Future.error('err')]).then((List<SettleResult> statuses) {
        expect(statuses[0], new SettleResult(SettleResult.COMPLETED, result: 'ok'));
        expect(statuses[1], new SettleResult(SettleResult.REJECTED, error: 'err'));
      });
    });

    group('SettleResult', () {
      test('return completed result when the future completes', () {
        expect(SettleResult.settle(new Future.value('ok')), completion(new SettleResult(SettleResult.COMPLETED, result: 'ok')));
      });

      test('return rejected result when the future completes', () {
        Exception error = new Exception('err');

        expect(SettleResult.settle(new Future.error(error)), completion(new SettleResult(SettleResult.REJECTED, error: error)));
      });

      test('toString for completed', () {
        expect(new SettleResult(SettleResult.COMPLETED, result: 'ok').toString(), 'SettleResult status:#completed result:ok');
      });

      test('toString for rejected', () {
        expect(new SettleResult(SettleResult.REJECTED, error: 'err').toString(), 'SettleResult status:#rejected error:err');
      });
    });

  });

  group('allCompleted', () {

    test('filter completed futures and return then', () {
      expect(allCompleted([new Future.value(1), new Future.error('err'), new Future.value(2)]), completion([1, 2]));
    });

  });

  group('allRejected', () {

    test('filter rejected futures and return then', () {
      expect(allRejected([new Future.value(1), new Future.error('err'), new Future.value(2)]), completion(['err']));
    });

  });
}