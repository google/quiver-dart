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

part of quiver.core;

/// A connected set of [Comparable] values.
///
/// If an interval [contains] two values, it also contains all values between
/// them.  It may have an [upper] and [lower] bound, and those bounds may be
/// open or closed.
class Interval<T extends Comparable<T>> {

  /// The lower bound value if it exists, or null.
  final T lower;

  /// The upper bound value if it exists, or null.
  final T upper;

  /// Whether `this` contains [lower].  If `false`, [lower] is still contained
  /// if [upperClosed] is true and [lower] compares equal to [upper].
  final bool lowerClosed;

  /// Whether `this` contains [upper].  If `false`, [upper] is still contained
  /// if [lowerClosed] is true and [lower] compares equal to [upper].
  final bool upperClosed;

  /// The lower [Bound].
  Bound get lowerBound => new Bound<T>(lower, lowerClosed);

  /// The upper [Bound].
  Bound get upperBound => new Bound<T>(upper, upperClosed);

  /// Whether `this` is both [lowerBounded] and [upperBounded].
  bool get bounded => lowerBounded && upperBounded;

  /// Whether `this` has a [lower] bound.
  bool get lowerBounded => lower != null;

  /// Whether `this` has an [upper] bound.
  bool get upperBounded => upper != null;

  /// Whether `this` excludes both of its bounds.
  bool get isOpen=> !lowerClosed && !upperClosed;

  /// Whether `this` [contains] both of its bounds.
  bool get isClosed => lowerClosed && upperClosed;

  /// Whether `this` excludes its bounds.
  bool get isClosedOpen => lowerClosed && !upperClosed;

  /// Whether `this` [contains] its bounds.
  bool get isOpenClosed => !lowerClosed && upperClosed;

  /// Whether `this` [contains] any values.
  bool get isEmpty  => _boundValuesEqual && !isClosed;

  /// Whether `this` [contains] exactly one value.
  bool get isSingleton => _boundValuesEqual && isClosed;

  bool get _boundValuesEqual =>
      bounded && Comparable.compare(lower, upper) == 0;

  /// Returns an interval which contains the same values as `this`, except any
  /// closed bounds become open.
  Interval<T> get interior => isOpen ? this : new Interval<T>(
      lowerBound: lower == null ? null : new Bound<T>.open(lower),
      upperBound: upper == null ? null : new Bound<T>.open(upper));

  /// Returns an interval which contains the same values as `this`, except any
  /// open bounds become closed.
  Interval<T> get closure => isClosed ? this : new Interval<T>(
      lowerBound: lower == null ? null : new Bound<T>.closed(lower),
      upperBound: upper == null ? null : new Bound<T>.closed(upper));

  /// An interval constructed from its [Bound]s.
  ///
  /// If [lowerBound] or [upperBound] are `null`, then the interval is unbounded
  /// in that direction.
  Interval(
      {Bound<T> lowerBound,
       Bound<T> upperBound})
      : lower = lowerBound == null ? lowerBound : lowerBound.value,
        upper = upperBound == null ? upperBound : upperBound.value,
        lowerClosed = lowerBound == null ? lowerBound : lowerBound.isClosed,
        upperClosed = upperBound == null ? upperBound : upperBound.isClosed {
    _checkNotOpenAndEqual(_checkBoundOrder());
  }

  Interval._(this.lower, this.upper, this.lowerClosed, this.upperClosed);

  /// `(`[lower]`..`[upper]`)`
  Interval.open(this.lower, this.upper)
      : lowerClosed = false,
        upperClosed = false {
    _checkNotOpenAndEqual(_checkBoundOrder());
  }

  /// `[`[lower]`..`[upper]`]`
  Interval.closed(this.lower, this.upper)
      : lowerClosed = true,
        upperClosed = true {
    if (lower == null) throw new ArgumentError('lower cannot be null');
    if (upper == null) throw new ArgumentError('upper cannot be null');
    _checkBoundOrder();
  }

  /// `(`[lower]`..`[upper]`]`
  Interval.openClosed(this.lower, this.upper)
      : lowerClosed = false,
        upperClosed = true {
    if (upper == null) throw new ArgumentError('upper cannot be null');
    _checkBoundOrder();
  }

  /// `[`[lower]`..`[upper]`)`
  Interval.closedOpen(this.lower, this.upper)
      : lowerClosed = true,
        upperClosed = false {
    if (lower == null) throw new ArgumentError('lower cannot be null');
    _checkBoundOrder();
  }

  int _checkBoundOrder() {
    if (lower == null || upper == null) return -1;
    var compare = Comparable.compare(lower, upper);
    if (compare > 0) {
      throw new ArgumentError('upper must not be less than lower');
    }
    return compare;
  }

  _checkNotOpenAndEqual(int compare) {
    if (compare == 0 && !lowerClosed && !upperClosed) {
      throw new ArgumentError('invalid empty open interval ( of form (v..v) )');
    }
  }

  /// `[`[lower]`.. +∞ )`
  Interval.atLeast(this.lower)
      : upper = null,
        lowerClosed = true,
        upperClosed = false {
    if (lower == null) throw new ArgumentError('lower cannot be null');
  }

  /// `( -∞ ..`[upper]`]`
  Interval.atMost(this.upper)
      : lower = null,
        lowerClosed = false,
        upperClosed = true {
    if (upper == null) throw new ArgumentError('upper cannot be null');
  }

  /// `(`[lower]`.. +∞ )`
  Interval.greaterThan(this.lower)
      : upper = null,
        lowerClosed = false,
        upperClosed = false;

  /// `( -∞ ..`[upper]`)`
  Interval.lessThan(this.upper)
      : lower = null,
        lowerClosed = false,
        upperClosed = false;

  /// `( -∞ .. +∞ )`
  Interval.all()
      : lower = null,
        upper = null,
        lowerClosed = false,
        upperClosed = false;

  /// `[`[value]`..`[value]`]`
  Interval.singleton(T value)
      : lower = value,
        upper = value,
        lowerClosed = true,
        upperClosed = true {
    if (value == null) throw new ArgumentError('value cannot be null');
  }

  /// The minimal interval which [contains] each value in [values].
  ///
  /// If [values] is empty, the returned interval contains all values.
  factory Interval.span(Iterable<T> all) {
    var iterator = all.iterator;
    var hasNext = iterator.moveNext();
    if (!hasNext) return new Interval<T>.all();
    var upper = iterator.current;
    var lower = iterator.current;
    while (iterator.moveNext()) {
      if (Comparable.compare(lower, iterator.current) > 0) lower = iterator.current;
      if (Comparable.compare(upper, iterator.current) < 0) upper = iterator.current;
    }
    return new Interval<T>.closed(lower, upper);
  }

  /// The minimal interval which [encloses] each interval in [intervals].
  ///
  /// If [intervals] is empty, the returned interval contains all values.
  factory Interval.encloseAll(Iterable<Interval<T>> intervals) {

    var iterator = intervals.iterator;
    if (!iterator.moveNext()) return new Interval<T>.all();
    var interval = iterator.current;
    var lower = interval.lower;
    var upper = interval.upper;
    var lowerClosed = interval.lowerClosed;
    var upperClosed = interval.upperClosed;
    while (iterator.moveNext()) {
      interval = iterator.current;
      if (interval.lower == null) {
        lower = null;
        lowerClosed = false;
        if (upper == null) break;
      } else {
        if (lower != null && Comparable.compare(lower, interval.lower) >= 0) {
          lower = interval.lower;
          lowerClosed = lowerClosed || interval.lowerClosed;
        }
      }
      if (interval.upper == null) {
        upper = null;
        upperClosed = false;
        if (lower == null) break;
      } else {
        if (upper != null && Comparable.compare(upper, interval.upper) <= 0) {
          upper = interval.upper;
          upperClosed = upperClosed || interval.upperClosed;
        }
      }
    }
    return new Interval<T>._(
        lower,
        upper,
        lowerClosed,
        upperClosed);
  }

  /// Whether `this` contains [test].
  bool contains(T test) {
    if (lower != null) {
      var lowerCompare = Comparable.compare(lower, test);
      if (lowerCompare > 0 || (!lowerClosed && lowerCompare == 0)) return false;
    }
    if (upper != null) {
      var upperCompare = Comparable.compare(upper, test);
      if (upperCompare < 0 || (!upperClosed && upperCompare == 0)) return false;
    }
    return true;
  }

  /// Whether `this` [contains] each value that [other] does.
  bool encloses(Interval<T> other) {
    if (lowerBounded) {
      if (!other.lowerBounded) {
        return false;
      } else {
        var lowerCompare = Comparable.compare(lower, other.lower);
        if (lowerCompare > 0 || (lowerCompare == 0 && !lowerClosed &&
            other.lowerClosed)) {
          return false;
        }
      }
    }
    if (upperBounded) {
      if (!other.upperBounded) {
        return false;
      } else {
        var upperCompare = Comparable.compare(upper, other.upper);
        if (upperCompare < 0 || (upperCompare == 0 && !upperClosed &&
            other.upperClosed)) {
          return false;
        }
      }
    }
    return true;
  }

  /// Whether the union of `this` and [other] is connected (i.e. is an
  /// [Interval]).
  bool connectedTo(Interval<T> other) {
    bool overlapping(Bound<T> lower, Bound<T> upper) {
      if (lower.value == null || upper.value == null) return true;
      var comparison = lower.value.compareTo(upper.value);
      return comparison < 0 ||
          (comparison == 0 && (lower.isClosed || upper.isClosed));
    }
    return overlapping(lowerBound, other.upperBound) &&
        overlapping(other.lowerBound, upperBound);
  }

  int get hashCode => hash4(lower, upper, lowerClosed, upperClosed);

  bool operator == (Interval<T> other) =>
      other is Interval<T> &&
      lower == other.lower &&
      upper == other.upper &&
      lowerClosed == other.lowerClosed &&
      upperClosed == other.upperClosed;

  String toString() {
    var open = '${lowerClosed ? '[' : '('}${lower == null ? '-∞' : lower}';
    var close = '${upper == null ? '+∞' : upper}${upperClosed? ']' : ')'}';
    return '$open..$close';
  }

}

/// Represents an upper or lower bound (or absence thereof) of an [Interval].
class Bound<T> {

  /// The boundary value.
  final T value;

  /// Whether `this` bound includes its [value].
  final bool isClosed;

  /// Whether `this` bound excludes its [value].
  bool get isOpen => !isClosed;

  Bound(this.value, this.isClosed) {
    if (isClosed == null) throw new ArgumentError('isClosed cannot be null');
    if (isClosed) _checkValue();
  }

  /// An open bound.
  Bound.open(this.value) : isClosed = false;

  /// A closed bound.
  Bound.closed(this.value) : isClosed = true { _checkValue(); }

  /// An absent bound.
  Bound.absent() : isClosed = false, value = null;

  _checkValue() {
    if (value == null) {
      throw new ArgumentError('value cannot be null when isClosed is true');
    }
  }

  int get hashCode => hash2(value, isClosed);

  bool operator == (Bound<T> other) =>
      other is Bound<T> &&
      value == other.value &&
      isClosed == other.isClosed;

}
