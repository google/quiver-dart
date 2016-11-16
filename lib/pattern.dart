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

/**
 * This library contains utilities for working with [RegExp]s and other
 * [Pattern]s.
 */
library quiver.pattern;

part 'src/pattern/glob.dart';

// From the PatternCharacter rule here:
// http://ecma-international.org/ecma-262/5.1/#sec-15.10
final _specialChars = new RegExp(r'([\\\^\$\.\|\+\[\]\(\)\{\}])');

/**
 * Escapes special regex characters in [str] so that it can be used as a
 * literal match inside of a [RegExp].
 *
 * The special characters are: \ ^ $ . | + [ ] ( ) { }
 * as defined here: http://ecma-international.org/ecma-262/5.1/#sec-15.10
 */
String escapeRegex(String str) => str.splitMapJoin(_specialChars,
    onMatch: (Match m) => '\\${m.group(0)}', onNonMatch: (s) => s);

/**
 * Returns a [Pattern] that matches against every pattern in [include] and
 * returns all the matches. If the input string matches against any pattern in
 * [exclude] no matches are returned.
 */
Pattern matchAny(Iterable<Pattern> include, {Iterable<Pattern> exclude}) =>
    new _MultiPattern(include, exclude: exclude);

class _MultiPattern extends Pattern {
  final Iterable<Pattern> include;
  final Iterable<Pattern> exclude;

  _MultiPattern(Iterable<Pattern> this.include,
      {Iterable<Pattern> this.exclude});

  Iterable<Match> allMatches(String str, [int start = 0]) {
    final _allMatches = <Match>[];
    for (var pattern in include) {
      var matches = pattern.allMatches(str, start);
      if (_hasMatch(matches)) {
        if (exclude != null) {
          for (var excludePattern in exclude) {
            if (_hasMatch(excludePattern.allMatches(str, start))) {
              return [];
            }
          }
        }
        _allMatches.addAll(matches);
      }
    }
    return _allMatches;
  }

  Match matchAsPrefix(String str, [int start = 0]) {
    return allMatches(str)
        .firstWhere((match) => match.start == start, orElse: () => null);
  }
}

/**
 * Returns true if [pattern] has a single match in [str] that matches the whole
 * string, not a substring.
 */
bool matchesFull(Pattern pattern, String str) {
  var match = pattern.matchAsPrefix(str);
  return match != null && match.end == str.length;
}

bool _hasMatch(Iterable<Match> matches) => matches.iterator.moveNext();
