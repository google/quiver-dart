// Copyright 2014 Google Inc. All Rights Reserved.
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

part of quiver.testing.matchers;

/// Compares two [DateTime] methods and returns true iff [value] is before
/// the compared date. For example:
///
/// expect(new DateTime(seconds:0), isBefore(new DateTime(seconds:1))
///
/// will pass whereas:
///
/// expect(new DateTime(seconds:0), isBefore(new DateTime(seconds:0))
///
/// will fail.
Matcher isBefore(DateTime value) =>
    new _DateTimeMatcher(value, _DateTimeComparator.before);

/// Compares two [DateTime] methods and returns true iff [value] is after
/// the compared date. For example:
///
/// expect(new DateTime(seconds:1), isAfter(new DateTime(seconds:0))
///
/// will pass whereas:
///
/// expect(new DateTime(seconds:0), isAfter(new DateTime(seconds:0))
///
/// will fail.
Matcher isAfter(DateTime value) =>
    new _DateTimeMatcher(value, _DateTimeComparator.after);

/// Compares two [DateTime] methods and returns true iff [value] is at the same
///  moment as the compared date. For example:
///
/// expect(new DateTime(seconds:1), isTheSameMoment(new DateTime(seconds:1))
///
/// will pass whereas:
///
/// expect(new DateTime(seconds:1), isBefore(new DateTime(seconds:0))
///
/// will fail.
Matcher isTheSameMomentAs(DateTime value) =>
    new _DateTimeMatcher(value, _DateTimeComparator.atTheSameMoment);

class _DateTimeMatcher extends Matcher {
  final DateTime _value;
  final _DateTimeComparator _comparator;

  const _DateTimeMatcher(this._value, this._comparator);

  @override
  Description describe(Description description) => description
      .add('a DateTime ${_comparator._description}')
      .add(' ')
      .add(_value.toIso8601String());

  @override
  bool matches(DateTime item, Map matchState) =>
      _comparator._compare(item, _value);

  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    mismatchDescription.add('is not ');
    return describe(mismatchDescription);
  }
}

typedef bool BooleanComparator<T>(T a, T b);

class _DateTimeComparator {
  static final before = new _DateTimeComparator._internal(
      (DateTime a, DateTime b) => a.isBefore(b), 'before');
  static final after = new _DateTimeComparator._internal(
      (DateTime a, DateTime b) => a.isAfter(b), 'after');
  static final atTheSameMoment = new _DateTimeComparator._internal(
      (DateTime a, DateTime b) => a.isAtSameMomentAs(b), 'at the same moment');

  final String _description;
  final BooleanComparator _compare;
  _DateTimeComparator._internal(this._compare, this._description);
}
