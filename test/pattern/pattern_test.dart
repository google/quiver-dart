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

library quiver.pattern_test;


import 'package:unittest/unittest.dart';
import 'package:quiver/pattern.dart';

final _specialChars = r'\^$.|+[](){}';

main() {

  group('escapeRegex', () {
    test('should escape special characters', () {
      for (var c in _specialChars.split('')) {
        expect(escapeRegex(c), '\\$c');
      }
    });
  });

  group('matchesAny', () {
    test('should match multiple include patterns', () {
      expectMatch(matchAny(['a', 'b']), 'a', ['a']);
      expectMatch(matchAny(['a', 'b']), 'b', ['b']);
    });

    test('should return multiple matches when more than one matches', () {
      expectMatch(matchAny(['a', 'b']), 'ab', ['a', 'b']);
    });

    test('should exclude', () {
      expectMatch(matchAny(['foo', 'bar'], exclude: ['foobar']), 'foobar', []);
    });
  });

  group('matchesFull', () {
    test('should match a string', () {
      expect(matchesFull('abcd', 'abcd'), true);
      expect(matchesFull(new RegExp('a.*d'), 'abcd'), true);
    });

    test('should return false for a partial match', () {
      expect(matchesFull('abc', 'abcd'), false);
      expect(matchesFull('bcd', 'abcd'), false);
      expect(matchesFull(new RegExp('a.*c'), 'abcd'), false);
      expect(matchesFull(new RegExp('b.*d'), 'abcd'), false);
    });
  });
}

expectMatch(Pattern pattern, String str, List<String> matches) {
  var actual = pattern.allMatches(str).map((m) => m.group(0)).toList();
  expect(actual, matches);
}
