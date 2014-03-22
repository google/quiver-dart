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

library quiver.streams.streambuffer_test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:quiver/streams.dart';

void main() {
  group("StreamBuffer", () {
    StreamBuffer<int> buf;
    setUp(() => buf = new StreamBuffer());
    test("returns orderly overlaps", () {
      var stream = new Stream.fromIterable([[1], [2,3,4], [5,6,7,8]]).pipe(buf);
      return Future.wait([buf.read(2), buf.read(4), buf.read(2)]).then((vals) {
        expect(vals[0], equals([1, 2]));
        expect(vals[1], equals([3, 4, 5, 6]));
        expect(vals[2], equals([7, 8]));
      }).then((_) {
        buf.close();
      });
    });
  });
}
