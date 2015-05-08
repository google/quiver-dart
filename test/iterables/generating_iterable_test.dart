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

library quiver.iterables.property_iterable_test;

import 'package:test/test.dart';
import 'package:quiver/iterables.dart';

main() {
  group('GeneratingIterable', () {
    test("should create an empty iterable for a null start object", () {
      var iterable = new GeneratingIterable(() => null, (n) => null);
      expect(iterable, []);
    });

    test("should create one-item empty iterable when next returns null", () {
      var iterable = new GeneratingIterable(() => "Hello", (n) => null);
      expect(iterable, ["Hello"]);
    });

    test("should add items until next returns null", () {
      var parent = new Node();
      var node = new Node()..parent = parent;
      var iterable = new GeneratingIterable<Node>(() => node, (n) => n.parent);
      expect(iterable, [node, parent]);
    });
  });
}

class Node {
  Node parent;
}
