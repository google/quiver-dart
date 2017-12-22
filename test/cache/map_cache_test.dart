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

library quiver.cache.map_cache_test;

import 'dart:async';
import 'package:test/test.dart';
import 'package:quiver/cache.dart';

main() {
  group('MapCache', () {
    MapCache<String, String> cache;

    setUp(() {
      cache = new MapCache<String, String>();
    });

    test("should return null for a non-existent key", () {
      return cache.get('foo').then((value) {
        expect(value, isNull);
      });
    });

    test("should return a previously set key/value pair", () {
      return cache
          .set('foo', 'bar')
          .then((_) => cache.get('foo'))
          .then((value) {
        expect(value, 'bar');
      });
    });

    test("should invalidate a key", () {
      return cache
          .set('foo', 'bar')
          .then((_) => cache.invalidate('foo'))
          .then((_) => cache.get('foo'))
          .then((value) {
        expect(value, null);
      });
    });

    test("should load a value given a synchronous loader", () {
      return cache.get('foo', ifAbsent: (k) => k + k).then((value) {
        expect(value, 'foofoo');
      });
    });

    test("should load a value given an asynchronous loader", () {
      return cache
          .get('foo', ifAbsent: (k) => new Future.value(k + k))
          .then((value) {
        expect(value, 'foofoo');
      });
    });

    test("should not make multiple requests for the same key", () async {
      int count = 0;

      Future<String> loader(String key) {
        count += 1;
        return new Future.delayed(
            const Duration(milliseconds: 1), () => "test");
      }

      await Future.wait([
        cache.get("test", ifAbsent: loader),
        cache.get("test", ifAbsent: loader),
      ]);

      expect(count, equals(1));
    });
  });
}
