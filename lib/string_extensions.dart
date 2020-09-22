// Copyright 2020 Google Inc. All Rights Reserved.
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

import 'strings.dart' as s;

extension StringExtensions on String {
  /// Returns [true] if the [String] is either null, empty or is solely made of
  /// whitespace characters (as defined by [String.trim]).
  ///
  /// See also:
  ///
  ///  * [isNotBlank]
  bool get isBlank => s.isBlank(this);

  /// Returns [true] if the [String] is neither null, empty nor is solely made
  /// of whitespace characters.
  ///
  /// See also:
  ///
  ///  * [isBlank]
  bool get isNotBlank => s.isNotBlank(this);

  /// Returns [true] if the [String] is either null or empty.
  ///
  /// See also:
  ///
  ///  * [isNotEmpty]
  bool get isEmpty => s.isEmpty(this);

  /// Returns [true] if the [String] is a not empty string.
  ///
  /// See also:
  ///
  ///  * [isEmpty]
  bool get isNotEmpty => s.isNotEmpty(this);

  /// Loops over the [String] and returns traversed characters. Takes arbitrary
  /// [from] and [to] indices. Works as a substitute for [String.substring],
  /// except it never throws [RangeError]. Supports negative indices. Think of
  /// an index as a coordinate in an infinite in both directions vector, filled
  /// with this repeating string, whose 0-th coordinate coincides with the 0-th
  /// character in [s]. Then [loop] returns the sub-vector defined by the
  /// interval ([from], [to]). [from] is inclusive. [to] is exclusive.
  ///
  /// This method throws exceptions on an empty string.
  ///
  /// If [to] is omitted or is [null] the traversing ends at the end of the loop.
  ///
  /// If [to] < [from], traverses [s] in the opposite direction.
  ///
  /// For example:
  ///
  /// 'Hello, World!'.loop(7) == 'World!'
  /// 'ab'.loop(0, 6) == 'ababab'
  /// 'test.txt'.loop(-3) == 'txt'
  /// 'ldwor'.loop(-3, 2) == 'world'
  String loop(int from, [int to]) => s.loop(this, from, to);

  /// Returns a [String] of length [width] padded with the same number of
  /// characters on the left and right from [fill]. On the right, characters are
  /// selected from [fill] starting at the end so that the last character in
  /// [fill] is the last character in the result. [fill] is repeated if
  /// necessary to pad.
  ///
  /// Returns this [String] if its length is equal to or greater than [width].
  ///
  /// If there are an odd number of characters to pad, then the right will be
  /// padded with one more than the left.
  String center(int width, String fill) => s.center(this, width, fill);

  /// Returns `true` if [other] is equal after being converted to lower
  /// case.
  bool equalsIgnoreCase(String other) => s.equalsIgnoreCase(this, other);

  /// Compares to [other] after converting to lower case.
  ///
  /// [other] must not be null.
  int compareIgnoreCase(String other) => s.compareIgnoreCase(this, other);
}

extension CodeUnitExtensions on int {
  /// Returns `true` if this Rune represents a digit.
  ///
  /// The definition of digit matches the Unicode `0x3?` range of Western
  /// European digits.
  bool get isDigit => s.isDigit(this);

  /// Returns `true` if this Rune represents a whitespace character.
  ///
  /// The definition of whitespace matches that used in [String.trim] which is
  /// based on Unicode 6.2. This maybe be a different set of characters than the
  /// environment's [RegExp] definition for whitespace, which is given by the
  /// ECMAScript standard: http://ecma-international.org/ecma-262/5.1/#sec-15.10
  bool get isWhitespace => s.isWhitespace(this);
}
