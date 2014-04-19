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

library quiver.collection.ternarymap_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

main() {

  group('TernaryMap', () {
    group('when empty', () {
      TernaryMap tmap;
      setUp(() => tmap = new TernaryMap());

      test("returns count = 0", () => expect(tmap.length, equals(0)));
      test("isEmpty", () => expect(tmap.isEmpty, isTrue));
      test("!isNotEmpty", () => expect(tmap.isNotEmpty, isFalse));
      test("returns null for null key", () => expect(tmap[null], isNull));
      test("returns null for empty key", () => expect(tmap[''], isNull));
      test("returns null for random key", () => expect(tmap['nope'], isNull));
      test("containsKey is false", () => expect(tmap.containsKey('nope'), isFalse));
      test("containsPrefix is false", () => expect(tmap.containsPrefix('n'), isFalse));
      test("prefixPriorty returns null", () => expect(tmap.prefixPriorty('n'), isNull));
      test("containsValue returns false", () => expect(tmap.containsValue(null), isFalse));
      test("forEach doesn't callback", () => tmap.forEach((k,v) => fail("callback from empty tree")));
      test("dfs doesn't call onKey", () {
        tmap.dfs(onKey: (k) => fail("callback from empty tree"));
        tmap.dfs(key: 'nope', onKey: (k) => fail("callback from empty tree"));
      });
      test("dfs doesn't call onValue", () {
        tmap.dfs(onValue: (k) => fail("callback from empty tree"));
        tmap.dfs(key: 'nope', onValue: (k) => fail("callback from empty tree"));
      });
      test("dfs doesn't call onKeyValue", () {
        tmap.dfs(onKeyValue: (k,v) => fail("callback from empty tree"));
        tmap.dfs(key: 'nope', onKeyValue: (k,v) => fail("callback from empty tree"));
      });
      test("keys returns and empty iterator", () {
        expect(tmap.keys, isNotNull);
        expect(tmap.keys.length, equals(0));
        tmap.keys.forEach((k) => fail("non-empty iterator"));
        expect(tmap.keys.first, isNull);
        expect(tmap.keys.last, isNull);
      });
      test("values returns and empty iterator", () {
        expect(tmap.values, isNotNull);
        expect(tmap.values.length, equals(0));
        tmap.values.forEach((k) => fail("non-empty iterator"));
        expect(tmap.values.first, isNull);
        expect(tmap.values.last, isNull);
      });
      test("remove behaves", () {
        expect(tmap.remove(null), isNull);
        expect(tmap.remove(''), isNull);
        expect(tmap.remove('none'), isNull);
      });
    });

    test("created from map works", () {
      var map = {
       'foo': 10,
       'bar': 20,
       'baz': 30,
      };
      var tmap = new TernaryMap<int>.from(map);
      expect(tmap, equals(map));
    });
    test("addAll works", () {
      var map = {
       'foo': 10,
       'bar': 20,
       'baz': 30,
      };
      var tmap = new TernaryMap<int>()..addAll(map);
      expect(tmap, equals(map));
    });

    group("with lorem words", () {
      TernaryMap tmap;
      List<String> words;
      List<String> wordsSorted;

      setUp(() {
        words = new List.from([
            'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'dui', 'eget',
            'rhoncus', 'lectus', 'dignissim']);
        wordsSorted = new List.from(words)..sort();
        tmap = new TernaryMap.fromIterable(words);

      });

      test("is sorted by keys", () => expect(tmap.keys, equals(wordsSorted)));
      test("is sorted by values",
          () => expect(tmap.values, equals(wordsSorted)));
      test("containsPrefix('lor')",
          () => expect(tmap.containsPrefix('lor'), isTrue));
      test("does not containsKey('amet')",
          () => expect(tmap.containsKey('amet'), isTrue));
      test("does not containsKey('lor')",
          () => expect(tmap.containsKey('lor'), isFalse));
      test("containsValue('eget')",
          () => expect(tmap.containsValue('eget'), isTrue));
      test("does not containsValue('jtmcdole')",
          () => expect(tmap.containsValue('jtmcdole'), isFalse));
      test("searching for matching le* returns lectus",
          () => expect(tmap.prefixPriorty('le'), equals('lectus')));


      group("dfs starting with 'l' returns lectus lorem", () {
        var sub;
        setUp(() => sub = new List.from(['lectus', 'lorem']));

        test("with onKey", () {
          tmap.dfs(key: 'l', onKey: (k) {
            expect(k, equals(sub.removeAt(0)));
          });
          expect(sub.length, equals(0));
        });
        test("with onValue", () {
          tmap.dfs(key: 'l', onValue: (v) {
            expect(v, equals(sub.removeAt(0)));
          });
          expect(sub.length, equals(0));
        });
        test("with onKeyValue", () {
          tmap.dfs(key: 'l', onKeyValue: (k,v) {
            expect(k, equals(sub.removeAt(0)));
          });
          expect(sub.length, equals(0));
        });
      });

      test("clears", () {
        tmap.clear();
        expect(tmap.length, equals(0));
      });
      test("forEach is sorted", () {
        tmap.forEach((k,v) {
          expect(k , equals(wordsSorted.removeAt(0)));
        });
        expect(wordsSorted.length, equals(0));
      });
      test("dfs is sorted", () {
        tmap.dfs(onKey: (k) {
          expect(k , equals(wordsSorted.removeAt(0)));
        });
        expect(wordsSorted.length, equals(0));
      });
      test("works with [] and []= operators", () {
        expect(tmap['foo'], isNull);
        tmap['foo'] = 'bar';
        expect(tmap['foo'], equals('bar'));
        tmap['foo'] = 'baz';
        expect(tmap['foo'], equals('baz'));
      });
      test("[] amd []= ignores empty keys", () {
        var len = tmap.length;
        tmap[''] = 'bar';
        expect(tmap.length, equals(len));
        expect(tmap.containsValue('bar'), isFalse);
        expect(tmap[''], isNull);
      });
      test("can put if absent", () {
        expect(tmap['foo'], isNull);
        expect(tmap.putIfAbsent('foo', () => 'bar'), equals('bar'));
        expect(tmap.putIfAbsent('foo', () => fail("foo exists")), equals('bar'));
      });
      test("can remove words", () {
        var idxs = [4, 7, 1];
        for (int i in idxs) {
          expect(tmap.remove(wordsSorted[i]), equals(wordsSorted[i]));
          wordsSorted.removeAt(i);
        }
        tmap.forEach((k,v) {
          expect(k , equals(wordsSorted.removeAt(0)));
        });
      });

      group("iterator throws", () {
        BidirectionalIterator itr;
        setUp(() {
          itr = tmap.keys.iterator;
        });
        test("when moving next", () {
          try {
            tmap.remove('dui');
            itr.moveNext();
          } catch (e) {
            expect(e, isConcurrentModificationError);
          }
        });
        test("when moving previous", () {
          try {
            tmap.remove('dolor');
            itr.movePrevious();
          } catch (e) {
            expect(e, isConcurrentModificationError);
          }
        });
      });

      group("and prefix iterator over 'dignissim', 'dolor', 'dui',", () {
        var sub;
        setUp(() {
          sub = new List.from(['dignissim', 'dolor', 'dui']);
        });
        group("valuesForPrefix", () {
          Iterable iterable;
          setUp(() => iterable = tmap.valuesForPrefix('d'));
          test("iterates", () {
            for (String value in iterable) {
              expect(value, equals(sub.removeAt(0)));
            }
            expect(sub.length, equals(0), reason: "all elements covered");
          });
          test("first == dignissim", () {
            expect(iterable.first, equals('dignissim'));
          });
          test("contains('dolor')", () {
            expect(iterable.contains('dolor'), isTrue);
          });
          test("last == 'dui'", () {
            expect(iterable.last, equals('dui'));
          });
          test("length is 3", () {
            expect(tmap.valuesForPrefix('d').length, equals(3));
          });
        });
        group("keysForPrefix", () {
          Iterable iterable;
          setUp(() => iterable = tmap.keysForPrefix('d'));
          test("iterates", () {
            for (String value in iterable) {
              expect(value, equals(sub.removeAt(0)));
            }
            expect(sub.length, equals(0), reason: "all elements covered");
          });
          test("first == dignissim", () {
            expect(iterable.first, equals('dignissim'));
          });
          test("contains('dolor')", () {
            expect(iterable.contains('dolor'), isTrue);
          });
          test("last == 'dui'", () {
            expect(iterable.last, equals('dui'));
          });
          test("length is 3", () {
            expect(tmap.valuesForPrefix('d').length, equals(3));
          });
          test("forward-reverse", () {
            BidirectionalIterator itr = iterable.iterator;
            expect(itr.moveNext(), isTrue);
            expect(itr.moveNext(), isTrue);
            expect(itr.current, equals('dolor'));
            expect(itr.movePrevious(), isTrue);
            expect(itr.current, equals('dignissim'));
            expect(itr.movePrevious(), isFalse);
          });
          test("falloff right and return", () {
            BidirectionalIterator itr = iterable.iterator;
            while (itr.moveNext());
            expect(itr.current, isNull);
            expect(itr.movePrevious(), isTrue);
            expect(itr.current, equals('dui'));
          });
        });
      });
    });
  });
}