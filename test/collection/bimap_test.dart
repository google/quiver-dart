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

library quiver.collection.bimap_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

main() {
  group('BiMap', () {
    test('should construct a HashBiMap', () {
      expect(new BiMap() is HashBiMap, true);
    });
  });

  group('HashBiMap', () {
    BiMap<String, int> map;
    String k1 = 'k1', k2 = 'k2', k3 = 'k3';
    int v1 = 1, v2 = 2, v3 = 3;

    setUp(() {
      map = new HashBiMap();
    });

    test('should initialize empty', () {
      expect(map.isEmpty, true);
      expect(map.isNotEmpty, false);
      expect(map.inverse.isEmpty, true);
      expect(map.inverse.isNotEmpty, false);
    });

    test('should throw when adding a null key or value', () {
      expect(() => map[null] = v1, throwsA(new isInstanceOf<ArgumentError>()));
      expect(() => map[k1] = null, throwsA(new isInstanceOf<ArgumentError>()));
    });

    test('should throw when adding a null key or value via its inverse', () {
      expect(() => map.inverse[null] = k1,
             throwsA(new isInstanceOf<ArgumentError>()));
      expect(() => map.inverse[v1] = null,
             throwsA(new isInstanceOf<ArgumentError>()));
    });

    test('should not be empty after adding a mapping', () {
      map[k1] = v1;
      expect(map.isEmpty, false);
      expect(map.isNotEmpty, true);
      expect(map.inverse.isEmpty, false);
      expect(map.inverse.isNotEmpty, true);
    });

    test('should not be empty after adding a mapping via its inverse', () {
      map.inverse[v1] = k1;
      expect(map.isEmpty, false);
      expect(map.isNotEmpty, true);
      expect(map.inverse.isEmpty, false);
      expect(map.inverse.isNotEmpty, true);
    });

    test('should contain added mappings', () {
      map[k1] = v1;
      map[k2] = v2;
      expect(map[k1], v1);
      expect(map[k2], v2);
      expect(map.inverse[v1], k1);
      expect(map.inverse[v2], k2);
    });

    test('should contain mappings added via its invese', () {
      map.inverse[v1] = k1;
      map.inverse[v2] = k2;
      expect(map[k1], v1);
      expect(map[k2], v2);
      expect(map.inverse[v1], k1);
      expect(map.inverse[v2], k2);
    });

    test('should allow overwriting existing keys', () {
      map[k1] = v1;
      map[k1] = v2;
      expect(map[k1], v2);
      expect(map.inverse.containsKey(v1), false);
      expect(map.inverse[v2], k1);
    });

    test('should allow overwriting existing keys via its inverse', () {
      map.inverse[v1] = k1;
      map.inverse[v1] = k2;
      expect(map[k2], v1);
      expect(map.inverse.containsKey(v2), false);
      expect(map.inverse[v1], k2);
    });

    test('should allow overwriting existing key-value pairs', () {
      map[k1] = v1;
      map[k1] = v1;
      expect(map[k1], v1);
      expect(map.inverse.containsKey(v1), true);
      expect(map.inverse[v1], k1);
    });

    test('should allow overwriting existing key-value pairs via its inverse', () {
      map.inverse[v1] = k1;
      map.inverse[v1] = k1;
      expect(map[k1], v1);
      expect(map.inverse.containsKey(v1), true);
      expect(map.inverse[v1], k1);
    });

    test('should throw on overwriting unmapped keys with a mapped value', () {
      map[k1] = v1;
      expect(() => map[k2] = v1, throwsA(new isInstanceOf<ArgumentError>()));
      expect(map.containsKey(k2), false);
      expect(map.inverse.containsValue(k2), false);
    });

    test('should throw on overwriting unmapped keys with a mapped value via inverse', () {
      map[k1] = v1;
      expect(() => map.inverse[v2] = k1,
             throwsA(new isInstanceOf<ArgumentError>()));
      expect(map.containsValue(v2), false);
      expect(map.inverse.containsKey(v2), false);
    });

    test('should allow force-adding unmapped keys with a mapped value', () {
      map[k1] = v1;
      map.replace(k2, v1);
      expect(map[k2], v1);
      expect(map.containsKey(k1), false);
      expect(map.inverse[v1], k2);
      expect(map.inverse.containsValue(k1), false);
    });

    test('should allow force-adding unmapped keys with a mapped value via inverse', () {
      map.inverse[v1] = k1;
      map.inverse.replace(v2, k1);
      expect(map[k1], v2);
      expect(map.containsValue(v1), false);
      expect(map.inverse[v2], k1);
      expect(map.inverse.containsKey(v1), false);
    });

    test('should not contain removed mappings', () {
      map[k1] = v1;
      map.remove(k1);
      expect(map.containsKey(k1), false);
      expect(map.inverse.containsKey(v1), false);
    });

    test('should not contain mappings removed from its inverse', () {
      map[k1] = v1;
      map.inverse.remove(v1);
      expect(map.containsKey(k1), false);
      expect(map.inverse.containsKey(v1), false);
    });

    test('should be empty after clear', () {
      map[k1] = v1;
      map[k2] = v2;
      map.clear();
      expect(map.isEmpty, true);
      expect(map.inverse.isEmpty, true);
    });

    test('should be empty after inverse.clear', () {
      map[k1] = v1;
      map[k2] = v2;
      map.inverse.clear();
      expect(map.isEmpty, true);
      expect(map.inverse.isEmpty, true);
    });

    test('should contain mapped keys', () {
      map[k1] = v1;
      map[k2] = v2;
      expect(map.containsKey(k1), true);
      expect(map.containsKey(k2), true);
      expect(map.keys, unorderedEquals([k1, k2]));
      expect(map.inverse.containsKey(v1), true);
      expect(map.inverse.containsKey(v2), true);
      expect(map.inverse.keys, unorderedEquals([v1, v2]));
    });

    test('should contain keys mapped via its inverse', () {
      map.inverse[v1] = k1;
      map.inverse[v2] = k2;
      expect(map.containsKey(k1), true);
      expect(map.containsKey(k2), true);
      expect(map.keys, unorderedEquals([k1, k2]));
      expect(map.inverse.containsKey(v1), true);
      expect(map.inverse.containsKey(v2), true);
      expect(map.inverse.keys, unorderedEquals([v1, v2]));
    });

    test('should contain mapped values', () {
      map[k1] = v1;
      map[k2] = v2;
      expect(map.containsValue(v1), true);
      expect(map.containsValue(v2), true);
      expect(map.values, unorderedEquals([v1, v2]));
      expect(map.inverse.containsValue(k1), true);
      expect(map.inverse.containsValue(k2), true);
      expect(map.inverse.values, unorderedEquals([k1, k2]));
    });

    test('should contain values mapped via its inverse', () {
      map.inverse[v1] = k1;
      map.inverse[v2] = k2;
      expect(map.containsValue(v1), true);
      expect(map.containsValue(v2), true);
      expect(map.values, unorderedEquals([v1, v2]));
      expect(map.inverse.containsValue(k1), true);
      expect(map.inverse.containsValue(k2), true);
      expect(map.inverse.values, unorderedEquals([k1, k2]));
    });

    test('should add mappings via putIfAbsent if absent', () {
      map.putIfAbsent(k1, () => v1);
      expect(map[k1], v1);
      expect(map.inverse[v1], k1);
    });

    test('should add mappings via inverse.putIfAbsent if absent', () {
      map.inverse.putIfAbsent(v1, () => k1);
      expect(map[k1], v1);
      expect(map.inverse[v1], k1);
    });

    test('should not add mappings via putIfAbsent if present', () {
      map[k1] = v1;
      map.putIfAbsent(k1, () => v2);
      expect(map[k1], v1);
      expect(map.inverse[v1], k1);
      expect(map.inverse.containsKey(v2), false);
    });

    test('should not add mappings via inverse.putIfAbsent if present', () {
      map[k1] = v1;
      map.inverse.putIfAbsent(v1, () => k2);
      expect(map[k1], v1);
      expect(map.containsKey(k2), false);
      expect(map.inverse[v1], k1);
    });

    test('should contain mappings added from another map', () {
      map.addAll({
        k1: v1,
        k2: v2,
        k3: v3
      });
      expect(map[k1], v1);
      expect(map[k2], v2);
      expect(map[k3], v3);
      expect(map.inverse[v1], k1);
      expect(map.inverse[v2], k2);
      expect(map.inverse[v3], k3);
    });

    test('should contain mappings added via its inverse from another map', () {
      map.inverse.addAll({
        v1: k1,
        v2: k2,
        v3: k3
      });
      expect(map[k1], v1);
      expect(map[k2], v2);
      expect(map[k3], v3);
      expect(map.inverse[v1], k1);
      expect(map.inverse[v2], k2);
      expect(map.inverse[v3], k3);
    });

    test('should throw on adding from another map with duplicate values', () {
      expect(() => map.addAll({
        k1: v1,
        k2: v2,
        k3: v2
      }), throwsA(new isInstanceOf<ArgumentError>()));
    });

    test('should throw on adding from another map with duplicate values via inverse', () {
      expect(() => map.inverse.addAll({
        v1: k1,
        v2: k2,
        v3: k2
      }), throwsA(new isInstanceOf<ArgumentError>()));
    });

    test('should return the number of key-value pairs as its length', () {
      expect(map.length, 0);
      map[k1] = v1;
      expect(map.length, 1);
      map[k1] = v2;
      expect(map.length, 1);
      map.replace(k2, v2);
      expect(map.length, 1);
      map[k1] = v1;
      expect(map.length, 2);
    });

    test('should iterate over all pairs via forEach', () {
      map[k1] = v1;
      map[k2] = v2;
      var keys = [];
      var values = [];
      map.forEach((k, v) {
        keys.add(k);
        values.add(v);
      });
      expect(keys, unorderedEquals([k1, k2]));
      expect(values, unorderedEquals([v1, v2]));
    });

    test('should iterate over all pairs via forEach of its inverse', () {
      map[k1] = v1;
      map[k2] = v2;
      var keys = [];
      var values = [];
      map.inverse.forEach((k, v) {
        keys.add(k);
        values.add(v);
      });
      expect(keys, unorderedEquals([v1, v2]));
      expect(values, unorderedEquals([k1, k2]));
    });
  });
}

