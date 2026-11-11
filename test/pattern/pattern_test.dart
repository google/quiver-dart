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

import 'package:quiver/pattern.dart';
import 'package:test/test.dart';

const _specialChars = r'\^$.|+*?[](){}';

void main() {
  group('escapeRegex', () {
    test('should escape each special character as a valid literal RegExp', () {
      for (final c in _specialChars.split('')) {
        expect(escapeRegex(c), '\\$c');
        final re = RegExp('^${escapeRegex(c)}\$');
        expect(re.hasMatch(c), isTrue);
        expect(re.hasMatch('a'), isFalse);
      }
    });

    test('should escape all special characters in a single string', () {
      expect(
        escapeRegex(_specialChars),
        r'\\\^\$\.\|\+\*\?\[\]\(\)\{\}',
      );
      final re = RegExp('^${escapeRegex(_specialChars)}\$');
      expect(re.hasMatch(_specialChars), isTrue);
      expect(re.hasMatch('a'), isFalse);
    });

    test('should match strings containing * and ? quantifiers literally', () {
      final starRe = RegExp('^${escapeRegex('a*b')}\$');
      expect(starRe.hasMatch('a*b'), isTrue);
      expect(starRe.hasMatch('b'), isFalse);
      expect(starRe.hasMatch('ab'), isFalse);
      expect(starRe.hasMatch('aaab'), isFalse);

      final questionRe = RegExp('^${escapeRegex('a?b')}\$');
      expect(questionRe.hasMatch('a?b'), isTrue);
      expect(questionRe.hasMatch('ab'), isFalse);
      expect(questionRe.hasMatch('b'), isFalse);

      final repeatedRe = RegExp('^${escapeRegex('a**b??c.*?')}\$');
      expect(repeatedRe.hasMatch('a**b??c.*?'), isTrue);
      expect(repeatedRe.hasMatch('abc'), isFalse);
    });

    test('should prevent quantifier and alternation injection mid-pattern', () {
      final starMidRe = RegExp('^user_${escapeRegex('*')}_v\\d+\$');
      expect(starMidRe.hasMatch('user_*_v1'), isTrue);
      expect(starMidRe.hasMatch('user_v1'), isFalse);
      expect(starMidRe.hasMatch('user____v1'), isFalse);

      final questionMidRe = RegExp('^user_${escapeRegex('?')}_v\\d+\$');
      expect(questionMidRe.hasMatch('user_?_v1'), isTrue);
      expect(questionMidRe.hasMatch('user_v1'), isFalse);
      expect(questionMidRe.hasMatch('user__v1'), isFalse);

      final altMidRe = RegExp('^user_${escapeRegex('a|admin')}_v\\d+\$');
      expect(altMidRe.hasMatch('user_a|admin_v1'), isTrue);
      expect(altMidRe.hasMatch('user_a'), isFalse);
      expect(altMidRe.hasMatch('admin_v1'), isFalse);
    });

    test('should neutralize non-quantifier regex metacharacters and escapes',
        () {
      final dotPlusBraceRe = RegExp('^${escapeRegex('a.b+c{2}')}\$');
      expect(dotPlusBraceRe.hasMatch('a.b+c{2}'), isTrue);
      expect(dotPlusBraceRe.hasMatch('axbbcc'), isFalse);

      final charClassEscapeRe = RegExp('^${escapeRegex(r'[ab]\d\w')}\$');
      expect(charClassEscapeRe.hasMatch(r'[ab]\d\w'), isTrue);
      expect(charClassEscapeRe.hasMatch('a5x'), isFalse);

      final groupAnchorRe = RegExp('^${escapeRegex(r'(^ab$)')}\$');
      final match = groupAnchorRe.firstMatch(r'(^ab$)');
      expect(match, isNotNull);
      expect(match!.groupCount, 0);
      expect(groupAnchorRe.hasMatch('ab'), isFalse);
    });

    test('should leave non-special ASCII and Unicode characters unchanged', () {
      expect(escapeRegex(''), '');
      expect(
        escapeRegex('abcXYZ019-_/:=!<>~@#%&;", \t\n\x00\x7f'),
        'abcXYZ019-_/:=!<>~@#%&;", \t\n\x00\x7f',
      );
      expect(escapeRegex("'"), "'");
      expect(escapeRegex('αβγ↭🎯'), 'αβγ↭🎯');
      expect(escapeRegex('🎯*?'), r'🎯\*\?');
    });
  });

  group('matchesAny', () {
    test('should match multiple include patterns', () {
      expectMatch(matchAny(['a', 'b']), 'a', 0, ['a']);
      expectMatch(matchAny(['a', 'b']), 'b', 0, ['b']);
    });

    test('should match multiple include patterns (non-zero start)', () {
      expectMatch(matchAny(['a', 'b']), 'ba', 1, ['a']);
      expectMatch(matchAny(['a', 'b']), 'aab', 2, ['b']);
    });

    test('should return multiple matches', () {
      expectMatch(matchAny(['a', 'b']), 'ab', 0, ['a', 'b']);
    });

    test('should return multiple matches (non-zero start)', () {
      expectMatch(matchAny(['a', 'b', 'c']), 'cab', 1, ['a', 'b']);
    });

    test('should exclude', () {
      expectMatch(
          matchAny(['foo', 'bar'], exclude: ['foobar']), 'foobar', 0, []);
    });

    test('should exclude (non-zero start)', () {
      expectMatch(
          matchAny(['foo', 'bar'], exclude: ['foobar']), 'xyfoobar', 2, []);
    });
  });

  group('matchesFull', () {
    test('should match a string', () {
      expect(matchesFull('abcd', 'abcd'), true);
      expect(matchesFull(RegExp('a.*d'), 'abcd'), true);
    });

    test('should return false for a partial match', () {
      expect(matchesFull('abc', 'abcd'), false);
      expect(matchesFull('bcd', 'abcd'), false);
      expect(matchesFull(RegExp('a.*c'), 'abcd'), false);
      expect(matchesFull(RegExp('b.*d'), 'abcd'), false);
    });
  });
}

void expectMatch(Pattern pattern, String str, int start, List<String> matches) {
  var actual = pattern.allMatches(str, start).map((m) => m.group(0)).toList();
  expect(actual, matches);
}
