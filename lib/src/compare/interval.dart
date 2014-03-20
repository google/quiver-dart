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

part of quiver.compare;

class Interval<T extends Comparable<T>> {

  final T lower, upper;
  final bool lowerClosed, upperClosed;

  Bound get lowerBound {
    if(lower == null) return null;
    return new Bound<T>(lower, lowerClosed);
  }
  Bound get upperBound {
    if(upper == null) return null;
    return new Bound<T>(upper, upperClosed);
  }
  bool get bounded => lowerBounded && upperBounded;
  bool get lowerBounded => lower != null;
  bool get upperBounded => upper != null;
  bool get isOpen=> !lowerClosed && !upperClosed;
  bool get isClosed => lowerClosed && upperClosed;
  bool get isEmpty {
    if (lower == null || upper == null || Comparable.compare(lower, upper) < 0) return false;
    return !(lowerClosed && upperClosed);
  }
  bool get isSingleton {
    if(lower == null || upper == null) return false;
    return Comparable.compare(lower, upper) == 0 && isClosed;
  }
  Interval<T> get interior => isOpen ? this : new Interval<T>(
      lowerBound: lower == null ? null : new Bound<T>.open(lower),
      upperBound: upper == null ? null : new Bound<T>.open(upper));
  Interval<T> get closure => isClosed ? this : new Interval<T>(
      lowerBound: lower == null ? null : new Bound<T>.closed(lower),
      upperBound: upper == null ? null : new Bound<T>.closed(upper));

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

  Interval.open(this.lower, this.upper)
      : lowerClosed = false,
        upperClosed = false {
    _checkNotOpenAndEqual(_checkBoundOrder());
  }

  Interval.closed(this.lower, this.upper)
      : lowerClosed = true,
        upperClosed = true {
    if(lower == null) throw new ArgumentError('lower cannot be null');
    if(upper == null) throw new ArgumentError('upper cannot be null');
    _checkBoundOrder();
  }

  Interval.openClosed(this.lower, this.upper)
      : lowerClosed = false,
        upperClosed = true {
    if(upper == null) throw new ArgumentError('upper cannot be null');
    _checkBoundOrder();
  }

  Interval.closedOpen(this.lower, this.upper)
      : lowerClosed = true,
        upperClosed = false {
    if(lower == null) throw new ArgumentError('lower cannot be null');
    _checkBoundOrder();
  }

  int _checkBoundOrder() {
    if(lower == null || upper == null) return -1;
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

  Interval.atLeast(this.lower)
      : upper = null,
        lowerClosed = true,
        upperClosed = false {
    if(lower == null) throw new ArgumentError('lower cannot be null');
  }

  Interval.atMost(this.upper)
      : lower = null,
        lowerClosed = false,
        upperClosed = true {
    if(upper == null) throw new ArgumentError('upper cannot be null');
  }

  Interval.greaterThan(this.lower)
      : upper = null,
        lowerClosed = false,
        upperClosed = false;

  Interval.lessThan(this.upper)
      : lower = null,
        lowerClosed = false,
        upperClosed = false;

  Interval.all()
      : lower = null,
        upper = null,
        lowerClosed = false,
        upperClosed = false;

  Interval.singleton(T value)
      : lower = value,
        upper = value,
        lowerClosed = true,
        upperClosed = true {
    if(value == null) throw new ArgumentError('value cannot be null');
  }

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
      if(interval.lower == null) {
        lower = null;
        lowerClosed = false;
        if(upper == null) break;
      } else {
        if (lower != null && Comparable.compare(lower, interval.lower) >= 0) {
          lower = interval.lower;
          lowerClosed = lowerClosed || interval.lowerClosed;
        }
      }
      if(interval.upper == null) {
        upper = null;
        upperClosed = false;
        if(lower == null) break;
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

  bool contains(T test) {
    if (lower != null) {
      var lowerCompare = Comparable.compare(lower, test);
      if(lowerCompare > 0 || (!lowerClosed && lowerCompare == 0)) return false;
    }
    if (upper != null) {
      var upperCompare = Comparable.compare(upper, test);
      if(upperCompare < 0 || (!upperClosed && upperCompare == 0)) return false;
    }
    return true;
  }

  bool encloses(Interval<T> other) {
    if (lower != null) {
      if (other.lower == null) {
        return false;
      } else {
        var lowerCompare = Comparable.compare(lower, other.lower);
        if (lowerCompare > 0 || (lowerCompare == 0 && !lowerClosed && other.lowerClosed)) return false;
      }
    }
    if (upper != null) {
      if (other.upper == null) {
        return false;
      } else {
        var upperCompare = Comparable.compare(upper, other.upper);
        if (upperCompare < 0 || (upperCompare == 0 && !upperClosed && other.upperClosed)) return false;
      }
    }
    return true;
  }

  bool connectedTo(Interval<T> other) {
    if (lower != null) {
      if (other.lower != null) {
        var lowerCompare = Comparable.compare(lower, other.upper);
        if (lowerCompare > 0 || (lowerCompare == 0 && !lowerClosed && !other.upperClosed)) return false;
      }
    }
    if (upper != null) {
      if (other.upper != null) {
        var upperCompare = Comparable.compare(upper, other.lower);
        if (upperCompare < 0 || (upperCompare == 0 && !upperClosed && !other.lowerClosed)) return false;
      }
    }
    return true;
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

class Bound<T> {

  final T value;
  final bool isClosed;
  bool get isOpen => !isClosed;

  Bound(this.value, this.isClosed) {
    _checkValue();
    if(isClosed == null) throw new ArgumentError('isClosed cannot be null');
  }
  Bound.open(this.value) : isClosed = false { _checkValue(); }
  Bound.closed(this.value) : isClosed = true { _checkValue(); }
  _checkValue() {
    if(value == null) throw new ArgumentError('value cannot be null');
  }

  int get hashCode => hash2(value, isClosed);
  bool operator == (Bound<T> other) =>
      other is Bound<T> &&
      value == other.value &&
      isClosed == other.isClosed;

}
