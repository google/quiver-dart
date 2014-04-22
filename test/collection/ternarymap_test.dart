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
      test("depths returns [-1,-1]", () => expect(tmap.depths(), equals([-1,-1])));
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

    group("with [foo,bar,baz]", () {
      var map;
      setUp(() {
        map = {
         'foo': 10,
         'bar': 20,
         'baz': 30,
        };
      });
      test("created from map works", () {
        var tmap = new TernaryMap<int>.from(map);
        expect(tmap, equals(map));
      });
      test("addAll works", () {
        var tmap = new TernaryMap<int>()..addAll(map);
        expect(tmap, equals(map));
      });
      test("root depths is [3,5]", () {
        var tmap = new TernaryMap<int>.from(map);
        expect(tmap.depths(), [3,5]);
      });
      test("'b' depths is [4,4]", () {
        var tmap = new TernaryMap<int>.from(map);
        expect(tmap.depths(key: 'b'), [4,4]);
      });
      test("'c' depths is [-1,-1]", () {
        var tmap = new TernaryMap<int>.from(map);
        expect(tmap.depths(key: 'c'), [-1,-1]);
      });
      test("'baz' depths is [1,1]", () {
        var tmap = new TernaryMap<int>.from(map);
        expect(tmap.depths(key: 'c'), [-1,-1]);
      });
    });

    group("with junk words", () {
      TernaryMap tmap;
      List<String> words;
      List<String> wordsSorted;

      setUp(() {
        words = new List.from([
            'a', 'ab', 'abb', 'aba', 'b', 'ba', 'bb']);
        wordsSorted = new List.from(words)..sort();
        tmap = new TernaryMap.fromIterable(words);
      });
      test("is sorted by keys", () =>
          expect(tmap.keys, equals(wordsSorted)));
      test("is sorted by values",
          () => expect(tmap.values, equals(wordsSorted)));
    });

    test("root inclusive/exclusive keys", () {
      var words = [
        'b', 'a', 'c',
      ];
      TernaryMap map = new TernaryMap.fromIterable(words);
      expect(map.keysFor('b'), []);
      expect(map.keysFor('b', inclusive: true), ['b']);
    });

    test("root inclusive/exclusive values", () {
      var words = [
        'b', 'a', 'c',
      ];
      TernaryMap map = new TernaryMap.fromIterable(words);
      expect(map.valuesFor('b'), []);
      expect(map.valuesFor('b', inclusive: true), ['b']);
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
        expect(tmap['fool'], isNull);
        expect(tmap.putIfAbsent('fool', () => 'bar'), equals('bar'));
        expect(tmap.putIfAbsent('fool',
            () => fail("fool exists")), equals('bar'));
        expect(tmap.putIfAbsent('foo', () => 'baz'), equals('baz'));
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

      group("iterator throws on modification", () {
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

      group("coverage only", () {
        test("left-dangling-predecessor", () {
          var list = ['bat', 'bar'];
          TernaryMap map = new TernaryMap.fromIterable(list);
          var itr = map.values.iterator;
          while(itr.moveNext());
          while(itr.movePrevious()) {
            expect(itr.current, equals(list.removeAt(0)));
          }
          expect(list.length, equals(0));
        });
        test("right-dangling-predecessor", () {
          var list = ['bars', 'bat'];
          TernaryMap map = new TernaryMap.fromIterable(list);
          var itr = map.values.iterator;
          while(itr.moveNext());
          while(itr.movePrevious()) {
            expect(itr.current, equals(list.removeLast()));
          }
          expect(list.length, equals(0));
        });
        test("lookupPath center", () {
          var list = ['bar', 'bars'];
          TernaryMap map = new TernaryMap.fromIterable(list);
          var itr = map.keysFor('bar');
          expect(itr.length, equals(1));
          expect(itr.first, equals('bars'));
        });
        test("lookupPath right", () {
          var list = ['bar', 'bat'];
          TernaryMap map = new TernaryMap.fromIterable(list);
          var itr = map.keysFor('bat');
          expect(itr.length, equals(0));
        });
        test("lookupPath no key", () {
          var list = ['bar'];
          TernaryMap map = new TernaryMap.fromIterable(list);
          var itr = map.keysFor('bars');
          expect(itr.length, equals(0));
        });
        test("iterator path deadend", () {
          var list = ['bar', 'bars'];
          TernaryMap map = new TernaryMap.fromIterable(list);
          var itr = map.keysFor('bars');
          expect(itr.length, equals(0));
        });
        test("predecessor left-branch", () {
          var list = ['b', 'a', 'c'];
          TernaryMap map = new TernaryMap.fromIterable(list);
          map.remove('b');
          BidirectionalIterator itr = map.keys.iterator;
          expect(itr.moveNext(), isTrue);
          expect(itr.moveNext(), isTrue);
          expect(itr.current, 'c');
          expect(itr.movePrevious(), isTrue);
          expect(itr.current, 'a');
        });
      });
    });


    generateIterativeTest(String name, Function getIterable(TernaryMap map)) {
      group(name, () {
        List<String> words;
        TernaryMap map;

        setUp(() {
          words = new List.from([
              'cad', 'a', 'add', 'b', 'bad', 'abs', 'bard', 'bars',
          ]);
          map = new TernaryMap.fromIterable(words);
        });

        group("prefix.+", () {
          test("with root value", () {
            expect(getIterable(map)('b'),
                ['bad', 'bard', 'bars'],
                reason: "exclusive 'b' should only return b.+");
          });
          test("with empty root value", () {
            map.remove('b');
            expect(getIterable(map)('b'),
                ['bad', 'bard', 'bars'],
                reason: "exclusive 'b' should only return b.+");
          });
          test("first is bad",
              () => expect(getIterable(map)('b').first, 'bad'));
          test("last is bars",
              () => expect(getIterable(map)('b').last, 'bars'));
          test("!contains 'b'", () {
            expect(getIterable(map)('b').contains('b'), isFalse);
          });
          test("contains 'bard'", () {
            expect(getIterable(map)('b').contains('bard'), isTrue);
          });
          test("length is 3",
              () => expect(getIterable(map)('b').length, 3));
          test("iterative sweep", () {
            var match = ['bad', 'bard', 'bars'];
            var expected = new List.from(match);
            Iterable<String> ible = getIterable(map)('b');
            BidirectionalIterator<String> itr = ible.iterator;
            expect(itr.current, isNull);
            while(itr.moveNext()) {
              expect(itr.current, expected.removeAt(0));
            }
            expect(expected.length, 0);
            expected = new List.from(match.reversed);
            expect(itr.current, isNull);
            while(itr.movePrevious()) {
              expect(itr.current, expected.removeAt(0));
            }
            expect(itr.current, isNull);
            expect(expected.length, 0);
            expect(itr.moveNext(), isTrue);
            expect(itr.current, match[0]);
          });
          test("empty for 'cad'", () {
            expect(getIterable(map)('cad'), []);
          });
        });
        group("prefix.*", () {
          test("with root value", () {
            expect(getIterable(map)('b', inclusive: true),
                ['b', 'bad', 'bard', 'bars'],
                reason: "inclusive 'b' should return all b.*");
          });
          test("with empty root value", () {
            map.remove('b');
            expect(getIterable(map)('b', inclusive: true),
                ['bad', 'bard', 'bars'],
                reason: "exclusive 'b' should only return b.+");
          });
          test("first is b",
              () => expect(getIterable(map)('b', inclusive: true).first, 'b'));
          test("last is bars",
              () => expect(getIterable(map)('b', inclusive: true).last,
                  'bars'));
          test("contains 'b'", () {
            expect(getIterable(map)('b', inclusive: true).contains('b'),
                isTrue);
          });
          test("contains 'bard'", () {
            expect(getIterable(map)('b').contains('bard'), isTrue);
          });
          test("length is 4",
              () => expect(getIterable(map)('b', inclusive: true).length, 4));
          test("iterative sweep", () {
            var match = ['b', 'bad', 'bard', 'bars'];
            var expected = new List.from(match);
            Iterable<String> ible = getIterable(map)('b', inclusive: true);
            BidirectionalIterator<String> itr = ible.iterator;
            expect(itr.current, isNull);
            while(itr.moveNext()) {
              expect(itr.current, expected.removeAt(0));
            }
            expect(expected.length, 0);
            expected = new List.from(match.reversed);
            expect(itr.current, isNull);
            while(itr.movePrevious()) {
              expect(itr.current, expected.removeAt(0));
            }
            expect(itr.current, isNull);
            expect(expected.length, 0);
            expect(itr.moveNext(), isTrue);
            expect(itr.current, match[0]);
          });
          test("one for 'cad'", () {
            expect(getIterable(map)('cad', inclusive: true), ['cad']);
          });
          test("coverage: movePrevious 'cad'", () {
            Iterable<String> ible = getIterable(map)('cad', inclusive: true);
            BidirectionalIterator<String> itr = ible.iterator;
            expect(itr.moveNext(), isTrue);
            expect(itr.current, 'cad');
            expect(itr.moveNext(), isFalse);
            expect(itr.current, isNull);
            expect(itr.movePrevious(), isTrue);
            expect(itr.current, 'cad');
          });
        });
      });
    }
    generateIterativeTest('keysFor', (map) => map.keysFor);
    generateIterativeTest('valuesFor', (map) => map.valuesFor);
  });
}