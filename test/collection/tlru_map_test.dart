// Copyright 2019 Google Inc. All Rights Reserved.
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

library quiver.collection.tlru_map_test;

import 'package:quiver/collection.dart';
import 'package:quiver/time.dart';
import 'package:test/test.dart';

void main() {
  /// clock to use for getting "real" values
  const Clock _clock = Clock();

  group('TlruMap standard operations', () {
    /// A map that will be initialized by individual tests.
    TlruMap<String, String> tlruMap;

    test('the length property reflects how many keys are in the map', () {
      tlruMap = TlruMap();
      expect(tlruMap, hasLength(0));

      tlruMap.addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});
      expect(tlruMap, hasLength(3));
    });

    test('accessing keys causes them to be promoted', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(tlruMap.keys.toList(), ['C', 'B', 'A']);

      // Trigger promotion of B.
      final _ = tlruMap['B'];

      // In a LRU cache, the first key is the one that will be removed if the
      // capacity is reached, so adding keys to the end is considered to be a
      // 'promotion'.
      expect(tlruMap.keys.toList(), ['B', 'C', 'A']);
    });

    test('new keys are added at the beginning', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      tlruMap['D'] = 'Delta';
      expect(tlruMap.keys.toList(), ['D', 'C', 'B', 'A']);
    });

    test('setting values on existing keys works, and promotes the key', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      tlruMap['B'] = 'Bravo';
      expect(tlruMap.keys.toList(), ['B', 'C', 'A']);
      expect(tlruMap['B'], 'Bravo');
    });

    test('updating values on existing keys works, and promotes the key', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      tlruMap.update('B', (v) => '$v$v');
      expect(tlruMap.keys.toList(), ['B', 'C', 'A']);
      expect(tlruMap['B'], 'BetaBeta');
    });

    test('updating values on absent keys works, and promotes the key', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      tlruMap.update('D', (v) => '$v$v', ifAbsent: () => 'Delta');
      expect(tlruMap.keys.toList(), ['D', 'C', 'B', 'A']);
      expect(tlruMap['D'], 'Delta');
    });

    test('updating all values works, and does not change used order', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});
      tlruMap.updateAll((k, v) => '$v$v');
      expect(tlruMap.keys.toList(), ['C', 'B', 'A']);
      expect(tlruMap['A'], 'AlphaAlpha');
      expect(tlruMap['B'], 'BetaBeta');
      expect(tlruMap['C'], 'CharlieCharlie');
    });

    test('the least recently used key is evicted when capacity hit', () {
      tlruMap = TlruMap(maximumSize: 3)
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      tlruMap['D'] = 'Delta';
      expect(tlruMap.keys.toList(), ['D', 'C', 'B']);
    });

    test('setting maximum size evicts keys until the size is met', () {
      tlruMap = TlruMap(maximumSize: 5)
        ..addAll({
          'A': 'Alpha',
          'B': 'Beta',
          'C': 'Charlie',
          'D': 'Delta',
          'E': 'Epsilon'
        });

      tlruMap.maximumSize = 3;
      expect(tlruMap.keys.toList(), ['E', 'D', 'C']);
    });

    test('accessing the `keys` collection does not affect position', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(tlruMap.keys.toList(), ['C', 'B', 'A']);

      void nop(String key) {}
      tlruMap.keys.forEach(nop);
      tlruMap.keys.forEach(nop);

      expect(tlruMap.keys.toList(), ['C', 'B', 'A']);
    });

    test('accessing the `values` collection does not affect position', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(tlruMap.values.toList(), ['Charlie', 'Beta', 'Alpha']);

      void nop(String key) {}
      tlruMap.values.forEach(nop);
      tlruMap.values.forEach(nop);

      expect(tlruMap.values.toList(), ['Charlie', 'Beta', 'Alpha']);
    });

    test('clearing removes all keys and values', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(tlruMap.isNotEmpty, isTrue);
      expect(tlruMap.keys.isNotEmpty, isTrue);
      expect(tlruMap.values.isNotEmpty, isTrue);

      tlruMap.clear();

      expect(tlruMap, isEmpty);
      expect(tlruMap.keys, isEmpty);
      expect(tlruMap.values, isEmpty);
    });

    test('`containsKey` returns true if the key is in the map', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(tlruMap.containsKey('A'), isTrue);
      expect(tlruMap.containsKey('D'), isFalse);
    });

    test('`containsValue` returns true if the value is in the map', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(tlruMap.containsValue('Alpha'), isTrue);
      expect(tlruMap.containsValue('Delta'), isFalse);
    });

    test('`forEach` returns all key-value pairs without modifying order', () {
      final keys = [];
      final values = [];

      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(tlruMap.keys.toList(), ['C', 'B', 'A']);
      expect(tlruMap.values.toList(), ['Charlie', 'Beta', 'Alpha']);

      tlruMap.forEach((key, value) {
        keys.add(key);
        values.add(value);
      });

      expect(keys, ['C', 'B', 'A']);
      expect(values, ['Charlie', 'Beta', 'Alpha']);
      expect(tlruMap.keys.toList(), ['C', 'B', 'A']);
      expect(tlruMap.values.toList(), ['Charlie', 'Beta', 'Alpha']);
    });

    test('`get entries` returns all entries', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      var entries = tlruMap.entries;
      expect(entries, hasLength(3));
      // MapEntry objects are not equal to each other; cannot use `contains`. :(
      expect(entries.singleWhere((e) => e.key == 'A').value, equals('Alpha'));
      expect(entries.singleWhere((e) => e.key == 'B').value, equals('Beta'));
      expect(entries.singleWhere((e) => e.key == 'C').value, equals('Charlie'));
    });

    test('addEntries adds items to the beginning', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      var entries = [const MapEntry('D', 'Delta'), const MapEntry('E', 'Echo')];
      tlruMap.addEntries(entries);
      expect(tlruMap.keys.toList(), ['E', 'D', 'C', 'B', 'A']);
    });

    test('addEntries adds existing items to the beginning', () {
      tlruMap = TlruMap()..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      var entries = [const MapEntry('B', 'Bravo'), const MapEntry('E', 'Echo')];
      tlruMap.addEntries(entries);
      expect(tlruMap.keys.toList(), ['E', 'B', 'C', 'A']);
    });

    test('Re-adding the head entry is a no-op', () {
      // See: https://github.com/google/quiver-dart/issues/357
      tlruMap = TlruMap();
      tlruMap['A'] = 'Alpha';
      tlruMap['A'] = 'Alpha';

      expect(tlruMap.keys.toList(), ['A']);
      expect(tlruMap.values.toList(), ['Alpha']);
    });

    group('`remove`', () {
      setUp(() {
        tlruMap = TlruMap()
          ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});
      });

      test('returns the value associated with a key, if it exists', () {
        expect(tlruMap.remove('A'), 'Alpha');
      });

      test('returns null if the provided key does not exist', () {
        expect(tlruMap.remove('D'), isNull);
      });

      test('can remove the last item (head and tail)', () {
        // See: https://github.com/google/quiver-dart/issues/385
        tlruMap = TlruMap(maximumSize: 1)
          ..addAll({'A': 'Alpha'})
          ..remove('A');
        tlruMap['B'] = 'Beta';
        tlruMap['C'] = 'Charlie';
        expect(tlruMap.keys.toList(), ['C']);
      });

      test('can remove the head', () {
        tlruMap.remove('C');
        expect(tlruMap.keys.toList(), ['B', 'A']);
      });

      test('can remove the tail', () {
        tlruMap.remove('A');
        expect(tlruMap.keys.toList(), ['C', 'B']);
      });

      test('can remove a middle entry', () {
        tlruMap.remove('B');
        expect(tlruMap.keys.toList(), ['C', 'A']);
      });

      test('can removeWhere items', () {
        tlruMap.removeWhere((k, v) => v.contains('h'));
        expect(tlruMap.keys.toList(), ['B']);
      });

      test('can removeWhere without changing order', () {
        tlruMap.removeWhere((k, v) => v.contains('A'));
        expect(tlruMap.keys.toList(), ['C', 'B']);
      });

      test('linkage correctly preserved on remove', () {
        tlruMap.remove('B');

        // Order is now [C, A]. Trigger promotion of A to check linkage.
        final _ = tlruMap['A'];

        final keys = <String>[];
        tlruMap.forEach((String k, String v) => keys.add(k));
        expect(keys, ['A', 'C']);
      });
    });

    test('the linked list is mutated when promoting an item in the middle', () {
      TlruMap<String, int> tlruMap = TlruMap(maximumSize: 3)
        ..addAll({'C': 1, 'A': 1, 'B': 1});
      // Order is now [B, A, C]. Trigger promotion of A.
      tlruMap['A'] = 1;

      // Order is now [A, B, C]. Trigger promotion of C to check linkage.
      final _ = tlruMap['C'];
      expect(tlruMap.length, tlruMap.keys.length);
      expect(tlruMap.keys.toList(), ['C', 'A', 'B']);
    });

    group('`putIfAbsent`', () {
      setUp(() {
        tlruMap = TlruMap()
          ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});
      });

      test('adds an item if it does not exist, and moves it to the MRU', () {
        expect(tlruMap.putIfAbsent('D', () => 'Delta'), 'Delta');
        expect(tlruMap.keys.toList(), ['D', 'C', 'B', 'A']);
      });

      test('does not add an item if it exists, but does promote it to MRU', () {
        expect(tlruMap.putIfAbsent('B', () => throw 'Oops!'), 'Beta');
        expect(tlruMap.keys.toList(), ['B', 'C', 'A']);
      });

      test('removes the LRU item if `maximumSize` exceeded', () {
        tlruMap.maximumSize = 3;
        expect(tlruMap.putIfAbsent('D', () => 'Delta'), 'Delta');
        expect(tlruMap.keys.toList(), ['D', 'C', 'B']);
      });

      test('handles maximumSize 1 correctly', () {
        tlruMap.maximumSize = 1;
        tlruMap.putIfAbsent('B', () => 'Beta');
        expect(tlruMap.keys.toList(), ['B']);
      });
    });

    test('test all null constructor', () {
      tlruMap = TlruMap(
          maximumSize: null, expireAfterAccess: null, expireAfterWrite: null);

      tlruMap.addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie', 'D': 'Delta'});
      tlruMap['E'] = 'Echo';

      expect(tlruMap.containsKey('A'), isTrue);
      expect(tlruMap['B'], 'Beta');
      expect(tlruMap.length, 5);
    });
  });

  group('Verify expireAfterAccess behavior', () {
    TlruMap<String, dynamic> tlruMap;

    /// value to return next time clock is called
    DateTime _nextTime;

    /// function that returns [_nextTime] value during testing.
    DateTime _nextTimeFunction() {
      return _nextTime ??= DateTime.now();
    }

    setUp(() {
      tlruMap = TlruMap(
          clock: Clock(_nextTimeFunction),
          expireAfterAccess: const Duration(seconds: 3));
    });

    test('simple expiration based on access time', () {
      _nextTime = _clock.now();
      tlruMap.addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      _nextTime = _nextTime.add(const Duration(seconds: 3));
      expect(tlruMap.containsKey('A'), isFalse);
      expect(tlruMap.containsKey('B'), isFalse);
      expect(tlruMap.containsKey('C'), isFalse);

      _nextTime = _nextTime.add(const Duration(seconds: 1));
      tlruMap['D'] = 'Delta';
      expect(tlruMap.containsKey('D'), isTrue);

      _nextTime = _nextTime.add(const Duration(seconds: 3));
      expect(tlruMap.containsKey('D'), isFalse);

      _nextTime = _clock.now();
      tlruMap['D'] = 'Delta';
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      expect(tlruMap['D'], 'Delta'); // updates access
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      expect(tlruMap['D'], 'Delta'); // updates access
      _nextTime = _nextTime.add(const Duration(seconds: 3));
      expect(tlruMap.containsKey('D'), isFalse);
    });

    test('test access expiration with operators', () {
      _nextTime = _clock.now();
      tlruMap.addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      _nextTime = _nextTime.add(const Duration(seconds: 2));
      // only update access on one entry
      expect(tlruMap['B'], 'Beta'); // updates access

      _nextTime = _nextTime.add(const Duration(seconds: 2));
      // test operator[] with an expired entry
      expect(tlruMap['A'], isNull);
      // containsValue updates access because it gets `values` first
      expect(tlruMap.containsValue('Beta'), isTrue);
      expect(tlruMap.containsValue('Charlie'), isFalse);

      // at this point ['B'] was accessed again because of `containsValue`

      _nextTime = _nextTime.add(const Duration(seconds: 1));
      tlruMap['D'] = 'Delta';

      int count = 0;
      tlruMap.forEach((key, value) {
        if (tlruMap.containsKey(key)) {
          count++;
        }
      });
      expect(count, 2);
      expect(tlruMap.entries.length, 2);

      _nextTime = _nextTime.add(const Duration(seconds: 3));
      // the updated entries should be gone after the expiration
      expect(tlruMap.entries, isEmpty);
    });
  });

  group('Verify expireAfterWrite behavior', () {
    TlruMap<String, dynamic> tlruMap;

    /// value to return next time clock is called
    DateTime _nextTime;

    /// function that returns [_nextTime] value during testing.
    DateTime _nextTimeFunction() {
      return _nextTime ??= DateTime.now();
    }

    setUp(() {
      tlruMap = TlruMap(
          clock: Clock(_nextTimeFunction),
          expireAfterWrite: const Duration(seconds: 5));
    });

    test('simple expire based on write time', () {
      _nextTime = _clock.now();
      tlruMap.addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      _nextTime = _nextTime.add(const Duration(seconds: 5));
      expect(tlruMap.containsKey('A'), isFalse);
      expect(tlruMap.containsKey('B'), isFalse);
      expect(tlruMap.containsKey('C'), isFalse);

      _nextTime = _nextTime.add(const Duration(seconds: 1));
      tlruMap['D'] = 'Delta';
      expect(tlruMap.containsKey('D'), isTrue);

      _nextTime = _nextTime.add(const Duration(seconds: 5));
      expect(tlruMap.containsKey('D'), isFalse);

      _nextTime = _clock.now();
      tlruMap['D'] = 'Delta';
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      expect(tlruMap['D'], 'Delta'); // updates access
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      expect(tlruMap['D'], 'Delta'); // updates access
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap.containsKey('D'), isFalse);
    });

    test('test write expiration with operators', () {
      _nextTime = _clock.now();
      tlruMap.addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      _nextTime = _nextTime.add(const Duration(seconds: 2));
      // only update access on one entry
      expect(tlruMap['B'], 'Beta'); // updates access

      _nextTime = _nextTime.add(const Duration(seconds: 2));
      // test operator[] - not expired here because not expiring by access
      expect(tlruMap['A'], 'Alpha');
      // containsValue updates access because it gets `values` first
      expect(tlruMap.containsValue('Beta'), isTrue);
      expect(tlruMap.containsValue('Charlie'), isTrue);

      // at this point ['B'] was accessed again because of `containsValue`
      // however it will expire due to write time in this test case

      _nextTime = _nextTime.add(const Duration(seconds: 1));
      tlruMap['D'] = 'Delta';

      int count = 0;
      tlruMap.forEach((key, value) {
        if (tlruMap.containsKey(key)) {
          count++;
        }
      });
      expect(count, 1);
      expect(tlruMap.entries.length, 1);

      _nextTime = _nextTime.add(const Duration(seconds: 5));
      // the new ['D'] entry should be gone after the expiration
      expect(tlruMap.entries, isEmpty);
    });
  });

  group('Verify multiple expiration behavior', () {
    TlruMap<String, dynamic> tlruMap;

    /// value to return next time clock is called
    DateTime _nextTime;

    /// function that returns [_nextTime] value during testing.
    DateTime _nextTimeFunction() {
      return _nextTime ??= DateTime.now();
    }

    setUp(() {
      tlruMap = TlruMap(
          clock: Clock(_nextTimeFunction),
          expireAfterAccess: const Duration(seconds: 3),
          expireAfterWrite: const Duration(seconds: 5));
    });

    test('test multiple expiration constructor exception', () {
      const argumentErrorMatcher = TypeMatcher<ArgumentError>();

      // no error if both are null
      expect(() {
        TlruMap(expireAfterAccess: null, expireAfterWrite: null);
      }, returnsNormally);

      // no error if only expireAfterAccess
      expect(() {
        TlruMap(
            expireAfterAccess: const Duration(seconds: 3),
            expireAfterWrite: null);
      }, returnsNormally);

      // no error if only expireAfterWrite
      expect(() {
        TlruMap(
            expireAfterAccess: null,
            expireAfterWrite: const Duration(seconds: 5));
      }, returnsNormally);

      // no error if expireAfterWrite > expireAfterAccess
      expect(() {
        TlruMap(
            expireAfterAccess: const Duration(seconds: 3),
            expireAfterWrite: const Duration(seconds: 5));
      }, returnsNormally);

      // error if expireAfterWrite >= expireAfterAccess
      expect(() {
        TlruMap(
            expireAfterAccess: const Duration(seconds: 5),
            expireAfterWrite: const Duration(seconds: 3));
      }, throwsA(argumentErrorMatcher));

      // error if expireAfterWrite >= expireAfterAccess
      expect(() {
        TlruMap(
            expireAfterAccess: const Duration(seconds: 10),
            expireAfterWrite: const Duration(seconds: 10));
      }, throwsA(argumentErrorMatcher));
    });

    test('simple expire based on access time', () {
      _nextTime = _clock.now();
      tlruMap.addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      _nextTime = _nextTime.add(const Duration(seconds: 3));
      expect(tlruMap.containsKey('A'), isFalse);
      expect(tlruMap.containsKey('B'), isFalse);
      expect(tlruMap.containsKey('C'), isFalse);

      _nextTime = _nextTime.add(const Duration(seconds: 1));
      tlruMap['D'] = 'Delta';
      expect(tlruMap.containsKey('D'), isTrue);

      _nextTime = _nextTime.add(const Duration(seconds: 3));
      expect(tlruMap.containsKey('D'), isFalse);

      _nextTime = _clock.now();
      tlruMap['D'] = 'Delta';
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      expect(tlruMap['D'], 'Delta'); // updates access
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      expect(tlruMap['D'], 'Delta'); // updates access
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      expect(tlruMap.containsKey('D'), isFalse);
    });

    test('test multi expiration with operators', () {
      _nextTime = _clock.now();
      tlruMap.addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      _nextTime = _nextTime.add(const Duration(seconds: 2));
      // only update access on one entry
      expect(tlruMap['B'], 'Beta'); // updates access

      _nextTime = _nextTime.add(const Duration(seconds: 2));
      // test operator[] with an expired entry
      expect(tlruMap['A'], isNull);
      // containsValue updates access because it gets `values` first
      expect(tlruMap.containsValue('Beta'), isTrue);
      expect(tlruMap.containsValue('Charlie'), isFalse);

      // at this point ['B'] was accessed again because of `containsValue`
      // however it will expire due to write time in this test case

      _nextTime = _nextTime.add(const Duration(seconds: 1));
      tlruMap['D'] = 'Delta';

      int count = 0;
      tlruMap.forEach((key, value) {
        if (tlruMap.containsKey(key)) {
          count++;
        }
      });
      expect(count, 1);
      expect(tlruMap.entries.length, 1);

      _nextTime = _nextTime.add(const Duration(seconds: 5));
      // the new ['D'] entry should be gone after the expiration
      expect(tlruMap.entries, isEmpty);
    });

    test('test multi expiration cleanup simple', () {
      // t+0: start all entries with the same lastWrite and lastAccess
      _nextTime = _clock.now();
      tlruMap.addAll({
        'A': 'Alpha',
        'B': 'Beta',
        'C': 'Charlie',
        'D': 'Delta',
        'E': 'Echo'
      });
      expect(tlruMap['C'], 'Charlie');

      // t+1: write ['C'] again so it has an updated lastWrite and lastAccess
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      tlruMap['C'] = 'Charles';

      // t+1: also touch lastAccess on ['B'] and ['D']
      expect(tlruMap['B'], isNotNull);
      expect(tlruMap['D'], isNotNull);

      // t+3: ['A'] and ['E'] should expire due to lastAccess
      //
      // notice that we don't want to test directly - we want something that
      // will call the cleanUp function and then we'll test the results
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      final keysT3 = tlruMap.keys;
      expect(keysT3.contains('A'), isFalse);
      expect(keysT3.contains('B'), isTrue);
      expect(keysT3.contains('C'), isTrue);
      expect(keysT3.contains('D'), isTrue);
      expect(keysT3.contains('E'), isFalse);
      expect(keysT3.length, 3);

      // t+3 : also touch lastAccess on ['C'] again so it will not expire due
      // to lastAccess when we're testing for other lastWrite expiration.
      expect(tlruMap['C'], 'Charles');

      // t+5: ['B'] and ['D'] should expire due to lastWrite expiration even
      // though the lastAccess is more recent than the lastWrite, but ['C']
      // should remain because we wrote a new value and updated lastWrite.
      //
      // notice that we don't want to test directly - we want something that
      // will call the cleanUp function and then we'll test the results
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      final keysT5 = tlruMap.keys;
      expect(keysT5.contains('B'), isFalse);
      expect(keysT5.contains('C'), isTrue);
      expect(keysT5.contains('D'), isFalse);
      expect(keysT5.length, 1);
    });
  });

  group('Verify more cleanup expiration behaviors', () {
    /// value to return next time clock is called
    DateTime _nextTime;

    /// function that returns [_nextTime] value during testing.
    DateTime _nextTimeFunction() {
      return _nextTime ??= DateTime.now();
    }

    test('test lastAccess expiration cleanup', () {
      // this test verifies behavior when the most recently used items with
      // more recent lastAccess times also have the oldest lastWrite times.

      TlruMap<String, dynamic> tlruMap = TlruMap(
          clock: Clock(_nextTimeFunction),
          expireAfterAccess: null,
          expireAfterWrite: const Duration(seconds: 20));

      // t+0
      _nextTime = _clock.now();
      tlruMap.addAll({
        'A': 'Alpha',
        'B': 'Bravo',
        'C': 'Charlie',
        'D': 'Delta',
        'E': 'Echo'
      });
      // t+1
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['D'], 'Delta');
      tlruMap['B'] = 'Bravo';
      // t+2
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['C'], 'Charlie');
      // t+3
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['B'], 'Bravo');
      tlruMap['D'] = 'Delta';
      // t+4
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['A'], 'Alpha');

      // t+10 - oldest entry by lastAccess should NOT drop off
      _nextTime = _nextTime.add(const Duration(seconds: 6));
      final keysT10 = tlruMap.keys;
      expect(keysT10.contains('E'), isTrue);

      // t+20 - some entries should drop off at this point
      _nextTime = _nextTime.add(const Duration(seconds: 10));
      final keysT20 = tlruMap.keys;
      expect(keysT20.contains('A'), isFalse);
      expect(keysT20.contains('B'), isTrue);
      expect(keysT20.contains('C'), isFalse);
      expect(keysT20.contains('D'), isTrue);
      expect(keysT20.contains('E'), isFalse);

      // t+21 - some entries should drop off at this point
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      final keysT21 = tlruMap.keys;
      expect(keysT21.contains('B'), isFalse);

      // t+23 - the remaining entries should drop off at this point
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      final keysT23 = tlruMap.keys;
      expect(keysT23.contains('D'), isFalse);
    });

    test('test lastWrite expiration cleanup', () {
      // this test verifies behavior when the most recently used items with
      // more recent lastAccess times also have the oldest lastWrite times.

      TlruMap<String, dynamic> tlruMap = TlruMap(
          clock: Clock(_nextTimeFunction),
          expireAfterAccess: const Duration(seconds: 10),
          expireAfterWrite: null);

      // t+0
      _nextTime = _clock.now();
      tlruMap.addAll({
        'A': 'Alpha',
        'B': 'Bravo',
        'C': 'Charlie',
        'D': 'Delta',
        'E': 'Echo'
      });
      // t+1
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['D'], 'Delta');
      tlruMap['B'] = 'Bravo';
      // t+2
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['C'], 'Charlie');
      // t+3
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['B'], 'Bravo');
      tlruMap['D'] = 'Delta';
      // t+4
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['A'], 'Alpha');

      // t+10 - oldest entry by lastAccess should drop off
      _nextTime = _nextTime.add(const Duration(seconds: 6));
      final keysT10 = tlruMap.keys;
      expect(keysT10.contains('E'), isFalse);
      expect(keysT10.length, 4);

      // t+12 - oldest entry by lastAccess should drop off
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      final keysT12 = tlruMap.keys;
      expect(keysT12.contains('C'), isFalse);
      expect(keysT12.length, 3);

      // t+13 - oldest entry by lastAccess should drop off
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      final keysT13 = tlruMap.keys;
      expect(keysT13.contains('B'), isFalse);
      expect(keysT13.contains('D'), isFalse);
      expect(keysT13.length, 1);

      // t+14 - oldest entry by lastAccess should drop off
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      final keysT14 = tlruMap.keys;
      expect(keysT14.contains('A'), isFalse);
      expect(keysT14, isEmpty);
    });

    test('test multi expiration cleanup', () {
      // this test verifies behavior when the most recently used items with
      // more recent lastAccess times also have the oldest lastWrite times.

      TlruMap<String, dynamic> tlruMap = TlruMap(
          clock: Clock(_nextTimeFunction),
          expireAfterAccess: const Duration(seconds: 10),
          expireAfterWrite: const Duration(seconds: 20));

      // t+0
      _nextTime = _clock.now();
      tlruMap.addAll({
        'A': 'Alpha',
        'B': 'Bravo',
        'C': 'Charlie',
        'D': 'Delta',
        'E': 'Echo'
      });
      // t+1
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['D'], 'Delta');
      tlruMap['B'] = 'Bravo';
      // t+2
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['C'], 'Charlie');
      // t+3
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['B'], 'Bravo');
      tlruMap['D'] = 'Delta';
      // t+4
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      expect(tlruMap['A'], 'Alpha');

      // t+10 - oldest entry by lastAccess should drop off
      _nextTime = _nextTime.add(const Duration(seconds: 6));
      final keysT10 = tlruMap.keys;
      expect(keysT10.contains('E'), isFalse);
      expect(keysT10.length, 4);

      // t+12 - oldest entry by lastAccess should drop off
      _nextTime = _nextTime.add(const Duration(seconds: 2));
      final keysT12 = tlruMap.keys;
      expect(keysT12.contains('C'), isFalse);
      expect(keysT12.length, 3);

      // t+13 - oldest entry by lastAccess should drop off
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      final keysT13 = tlruMap.keys;
      expect(keysT13.contains('B'), isFalse);
      expect(keysT13.contains('D'), isFalse);
      expect(keysT13.length, 1);

      // touch ['A'] so it doesn't expire by lastAccess time
      expect(tlruMap['A'], 'Alpha');

      // t+14 - ['A'] should still be present
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      final keysT14 = tlruMap.keys;
      expect(keysT14.contains('A'), isTrue);
      expect(keysT14.length, 1);

      // t+19 - ['A'] should still be present
      _nextTime = _nextTime.add(const Duration(seconds: 5));
      final keysT19 = tlruMap.keys;
      expect(keysT19.contains('A'), isTrue);
      expect(keysT19.length, 1);

      // t+20 - ['A'] should expire by lastWrite time
      _nextTime = _nextTime.add(const Duration(seconds: 1));
      final keysT20 = tlruMap.keys;
      expect(keysT20.contains('A'), isFalse);
      expect(keysT20.length, 0);
    });
  });
}
