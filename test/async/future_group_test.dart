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

library quiver.async.future_group_test;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:quiver/async.dart';

main() {
  group('FutureGroup', () {

    test('should complete when all added futures are complete', () {
      var group = new FutureGroup();
      var completer1 = new Completer();
      var completer2 = new Completer();
      bool completed = false;

      group.add(completer1.future);

      scheduleMicrotask(() {
        expect(completed, false);
        group.add(completer2.future);
        completer1.complete(1);
        scheduleMicrotask(() {
          expect(completed, false);
          completer2.complete(2);
          expect(completed, false);
        });
      });

      return group.future.then((results) {
        completed = true;
        expect(results, [1, 2]);
      });
    });

    test('should throw if adding a future after the group is completed', () {
      var group = new FutureGroup();
      var completer1 = new Completer();
      var completer2 = new Completer();

      group.add(completer1.future);
      completer1.complete(1);
      return new Future(() {
        expect(() => group.add(completer2.future), throws);
      });
    });

  });
}
