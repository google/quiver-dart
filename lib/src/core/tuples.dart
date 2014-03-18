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

class Tuple2<T1, T2> extends _Tuple {
  final T1 first;
  final T2 second;

  const Tuple2(this.first, this.second);

  Iterator get iterator => new _EfficientIndexAndLengthIterator(this);
  int get length => 2;
  T2 get last => second;
  elementAt(int i) {
    switch (i) {
      case 0: return first;
      case 1: return second;
      default: throw new RangeError.value(i);
    }
  }

  int get hashCode => hash2(first, second);
  bool operator == (Tuple2<T1, T2> other) =>
      other is Tuple2<T1, T2> &&
      first == other.first &&
      second == other.second;
}


class Tuple3<T1, T2, T3> extends _Tuple {
  final T1 first;
  final T2 second;
  final T3 third;

  const Tuple3(this.first, this.second, this.third);

  int get length => 3;
  T3 get last => third;
  elementAt(int i) {
    switch (i) {
      case 0: return first;
      case 1: return second;
      case 2: return third;
      default: throw new RangeError.value(i);
    }
  }

  int get hashCode => hash3(first, second, third);
  bool operator == (Tuple3<T1, T2, T3> other) =>
      other is Tuple3<T1, T2, T3> &&
      first == other.first &&
      second == other.second &&
      third == other.third;
}

class Tuple4<T1, T2, T3, T4> extends _Tuple {
  final T1 first;
  final T2 second;
  final T3 third;
  final T4 fourth;

  const Tuple4(this.first, this.second, this.third, this.fourth);

  int get length => 4;
  T4 get last => fourth;
  elementAt(int i) {
    switch (i) {
      case 0: return first;
      case 1: return second;
      case 2: return third;
      case 3: return fourth;
      default: throw new RangeError.value(i);
    }
  }

  int get hashCode => hash4(first, second, third, fourth);
  bool operator == (Tuple4<T1, T2, T3, T4> other) =>
      other is Tuple4<T1, T2, T3, T4> &&
      first == other.first &&
      second == other.second &&
      third == other.third &&
      fourth == other.fourth;
}

class _Tuple extends IterableBase {

  const _Tuple();

  Iterator get iterator => new _EfficientIndexAndLengthIterator(this);
}

class _EfficientIndexAndLengthIterator implements Iterator {

  final Iterable _iterable;
  int _index = -1;

  _EfficientIndexAndLengthIterator(this._iterable);

  get current => _index == -1 ? null : _iterable.elementAt(_index);

  bool moveNext() {
    if (++_index < _iterable.length) return true;
    _index = -1;
    return false;
  }
}
