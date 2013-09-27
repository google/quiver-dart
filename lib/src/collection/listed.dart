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

part of quiver.collection;

/**
 * An immutable list.
 *
 * Implements all non-modifying methods from [List] but does not extend it.
 *
 * Adds deep [:hashCode:] and [:equals:].
 *
 * Adds a [:+:] operator.
 */
class Listed<E> implements Iterable<E> {
  List<E> _list;

  Listed._withList(this._list);

  Listed(Iterable<E> source) {
    _list = new List<E>.from(source, growable: false);
  }

  Listed.checkedCast(Iterable source) {
    for (var item in source) {
      if (item is! E) throw new UnsupportedError("wrong type");
    }
    _list = new List<E>.from(source, growable: false);
  }

  Listed<E> operator+(o) {
    if (o is Iterable<E>) {
      var list = new List<E>.from(_list);
      for (var v in o) {
        if (v is! E) throw new UnsupportedError("wrong type");
        list.add(v);
      }
      return new Listed<E>._withList(list);
    } else if (o is E) {
      return this + [o];
    } else {
      throw new UnsupportedError("wrong type");
    }
  }

  Listed<E> replace(E element, E newElement) {
    List<E> newList = new List<E>.from(_list);
    newList[indexOf(element)] = newElement;
    return new Listed<E>._withList(newList);
  }

  bool operator ==(o) {
    if (identical(o, this)) return true;
    if (o is! Listed) return false;
    if (length != o.length) return false;
    for (var i = 0; i < length; ++i) {
      if (this[i] != o[i]) return false;
    }
    return true;
  }

  int get hashCode {
    int result = 13;
    for (E element in this) {
      result = result * 13 + element.hashCode;
    }
    return result;
  }

  String toString() => _list.toString();

  // Non-modifying methods from List.
  E operator [](int index) => _list[index];
  int get length => _list.length;
  Iterable<E> get reversed => _list.reversed;
  int indexOf(E element, [int start = 0]) => _list.indexOf(element, start);
  int lastIndexOf(E element, [int start]) => _list.lastIndexOf(element, start);
  Listed<E> sublist(int start, [int end]) => new Listed(_list.sublist(start, end));
  Iterable<E> getRange(int start, int end) => _list.getRange(start, end);
  Map<int, E> asMap() => _list.asMap();

  // Methods from Iterable.
  Iterator<E> get iterator => _list.iterator;
  Iterable map(f(E element)) => _list.map(f);
  Iterable<E> where(bool test(E element)) => _list.where(test);
  Iterable expand(Iterable f(E element)) => _list.expand(f);
  bool contains(E element) => _list.contains(element);
  void forEach(void f(E element)) => _list.forEach(f);
  E reduce(E combine(E value, E element)) => _list.reduce(combine);
  dynamic fold(var initialValue,
      dynamic combine(var previousValue, E element)) => _list.fold(initialValue, combine);
  bool every(bool test(E element)) => _list.every(test);
  String join([String separator = ""]) => _list.join(separator);
  bool any(bool test(E element)) => _list.any(test);
  List<E> toList({ bool growable: true }) => _list.toList(growable: growable);
  Set<E> toSet() => _list.toSet();
  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;
  Iterable<E> take(int n) => _list.take(n);
  Iterable<E> takeWhile(bool test(E value)) => _list.takeWhile(test);
  Iterable<E> skip(int n) => _list.skip(n);
  Iterable<E> skipWhile(bool test(E value)) => _list.skipWhile(test);
  E get first => _list.first;
  E get last => _list.last;
  E get single => _list.single;
  E firstWhere(bool test(E element), { E orElse() }) => _list.firstWhere(test, orElse: orElse);
  E lastWhere(bool test(E element), { E orElse() }) => _list.lastWhere(test, orElse: orElse);
  E singleWhere(bool test(E element)) => _list.singleWhere(test);
  E elementAt(int index) => _list.elementAt(index);
}
