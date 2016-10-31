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

part of quiver.pattern;

// TODO(justin): add more detailed documentation and explain how matching
// differs or is similar to globs in Python and various shells.
/// A [Pattern] that matches against filesystem path-like strings with
/// wildcards.
///
/// The pattern matches strings as follows:
///   * The whole string must match, not a substring
///   * Any non wildcard is matched as a literal
///   * '*' matches one or more characters except '/'
///   * '?' matches exactly one character except '/'
///   * '**' matches one or more characters including '/'
class Glob implements Pattern {
  final RegExp regex;
  final String pattern;

  Glob(String pattern)
      : pattern = pattern,
        regex = _regexpFromGlobPattern(pattern);

  Iterable<Match> allMatches(String str, [int start = 0]) =>
      regex.allMatches(str, start);

  Match matchAsPrefix(String string, [int start = 0]) =>
      regex.matchAsPrefix(string, start);

  bool hasMatch(String str) => regex.hasMatch(str);

  String toString() => pattern;

  int get hashCode => pattern.hashCode;

  bool operator ==(other) => other is Glob && pattern == other.pattern;
}

RegExp _regexpFromGlobPattern(String pattern) {
  var sb = new StringBuffer();
  sb.write('^');
  var chars = pattern.split('');
  for (var i = 0; i < chars.length; i++) {
    var c = chars[i];
    if (_specialChars.hasMatch(c)) {
      sb.write('\\$c');
    } else if (c == '*') {
      if ((i + 1 < chars.length) && (chars[i + 1] == '*')) {
        sb.write('.*');
        i++;
      } else {
        sb.write('[^/]*');
      }
    } else if (c == '?') {
      sb.write('[^/]');
    } else {
      sb.write(c);
    }
  }
  sb.write(r'$');
  return new RegExp(sb.toString());
}
