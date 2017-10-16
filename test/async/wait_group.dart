// Copyright 2017 Google Inc. All Rights Reserved.
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

library quiver.async.wait_group_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:quiver/async.dart';

main() {
  test('joins Futures', () {
    final Completer<int> completer1 = new Completer.sync();
    final Completer<int> completer2 = new Completer.sync();

    List<int> resultList;

    waitGroup(
      <Future<int>>[completer1.future, completer2.future]
    ).then((List<int> result) => resultList = result);

    expect(resultList, null);
    completer1.complete(1);
    expect(resultList, null);
    completer2.complete(2);
    expect(resultList, <int>[1, 2]);
  });

  test('trims nulls', () {
    final Completer<int> completer1 = new Completer.sync();

    List<int> resultList;

    waitGroup(
      <Future<int>>[completer1.future, null]
    ).then((List<int> result) => resultList = result);

    expect(resultList, null);
    completer1.complete(1);
    expect(resultList, <int>[1]);
  });
}
