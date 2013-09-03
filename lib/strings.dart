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

library quiver.strings;

/**
 * Returns [true] if [s] is either null, empty or is solely made of whitespace
 * characters (as defined by [String.trim].
 */
bool isBlank(String s) => s == null || s.trim().isEmpty;

/**
 * Returns a string with characters from the given [s] in reverse order.
 */
String flip(String s) {
  if (s == null || s == '') return s;
  StringBuffer sb = new StringBuffer();
  var runes = s.runes;
  for (int i = runes.length - 1; i >= 0; i--) {
    sb.writeCharCode(runes.elementAt(i));
  }
  return sb.toString();
}

/**
 * If [s] is [null] returns empty string, otherwise returns [s] as is.
 */
String nullToEmpty(String s) => s == null ? '' : s;

/**
 * If [s] is an empty string returns [null], otherwise returns [s] as is.
 */
String emptyToNull(String s) => s == '' ? null : s;

/**
 * Concatenates [s] to itself a given number of [times]. Empty and null
 * strings will always result in empty and null strings respectively no matter
 * how many [times] they are [repeat]ed.
 *
 * If [times] is negative, returns the [flip]ped string repeated given number
 * of [times].
 */
String repeat(String s, int times) {
  if (s == null || s == '') return s;
  if (times < 0) {
    return repeat(flip(s), -times);
  }
  StringBuffer sink = new StringBuffer();
  _repeat(sink, s, times);
  return sink.toString();
}

/**
 * Loops over [s] and returns traversed characters. Takes arbitrary [from] and
 * [to] indices. Works as a substitute for [String.substring], except it never
 * throws [RangeError]. Supports negative indices. Think of an index as a
 * coordinate in an infinite in both directions vector filled with repeating
 * string [s], whose 0-th coordinate coincides with the 0-th character in [s].
 * Then [loop] returns the sub-vector defined by the interval ([from], [to]).
 * [from] is inclusive. [to] is exclusive.
 *
 * This method throws exceptions on [null] and empty strings.
 *
 * If [to] is omitted or is [null] the traversing ends at the end of the loop.
 *
 * If [to] < [from], traverses [s] in the opposite direction.
 *
 * For example:
 *
 * loop('Hello, World!', 7) == 'World!'
 * loop('ab', 6) == 'ababab'
 * loop('test.txt', -3) == 'txt'
 * loop('ldwor', -3, 2) == 'world'
 */
String loop(String s, int from, [int to]) {
  if (s == null || s == '') {
    throw new ArgumentError('Input string cannot be null or empty');
  }
  if (to != null && to < from) {
    return loop(flip(s), -from, -to);
  }
  int len = s.length;
  int leftFrag = from >= 0 ? from ~/ len : ((from - len) ~/ len);
  if (to == null) {
    to = (leftFrag + 1) * len;
  }
  int rightFrag = to - 1 >= 0 ? to ~/ len : ((to - len) ~/ len);
  int fragOffset = rightFrag - leftFrag - 1;
  if (fragOffset == -1) {
    return s.substring(from - leftFrag * len, to - rightFrag * len);
  }
  StringBuffer sink = new StringBuffer(s.substring(from - leftFrag * len));
  _repeat(sink, s, fragOffset);
  sink.write(s.substring(0, to - rightFrag * len));
  return sink.toString();
}

void _repeat(StringBuffer sink, String s, int times) {
  for (int i = 0; i < times; i++) {
    sink.write(s);
  }
}
