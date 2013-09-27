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
 * An immutable set.
 *
 * Implements all non-modifying methods from [Set] but does not extend it.
 *
 * Adds deep [:hashCode:] and [:equals:].
 *
 * Adds a [:+:] operator.
 */
class Setted<E> implements Iterable<E> {
  LinkedHashSet<E> _set;

  Setted._withSet(this._set);

  Setted(Iterable<E> source) {
    _set = new LinkedHashSet<E>();
    _set.addAll(source);
  }

  Setted.checkedCast(Iterable source) {
    for (var item in source) {
      if (item is! E) throw new ArgumentError("wrong type");
    }
    _set = new LinkedHashSet<E>();
    _set.addAll(source);
  }

  Setted<E> operator+(o) {
    if (o is Iterable<E>) {
      var set = new LinkedHashSet<E>();
      set.addAll(_set);
      for (var v in o) {
        if (v is! E) throw new ArgumentError("wrong type");
        set.add(v);
      }
      return new Setted<E>._withSet(set);
    } else if (o is E) {
      return this + [o];
    } else {
      throw new ArgumentError("wrong type");
    }
  }

  bool operator ==(o) {
    if (identical(o, this)) return true;
    if (o is! Setted) return false;
    if (length != o.length) return false;
    for (var v in this) {
      if (!o.contains(v)) {
        return false;
      }
    }
    return true;
  }

  int get hashCode {
    int result = 5973 * length;
    for (E element in this) {
      result += element.hashCode;
    }
    return result;
  }

  // Non-modifying methods from [Set].
  int get length => _set.length;
  bool get isEmpty => _set.isEmpty;
  bool get isNotEmpty => _set.isNotEmpty;
  bool contains(Object object) => _set.contains(object);
  void forEach(void action(E element)) => _set.forEach(action);
  E get first => _set.first;
  E get last => _set.last;
  E get single => _set.single;

  // Methods from Iterable.
  Iterator<E> get iterator => _set.iterator;
  Iterable map(f(E element)) => _set.map(f);
  Iterable<E> where(bool test(E element)) => _set.where(test);
  Iterable expand(Iterable f(E element)) => _set.expand(f);
  E reduce(E combine(E value, E element)) => _set.reduce(combine);
  dynamic fold(var initialValue,
      dynamic combine(var previousValue, E element)) => _set.fold(initialValue, combine);
  bool every(bool test(E element)) => _set.every(test);
  String join([String separator = ""]) => _set.join(separator);
  bool any(bool test(E element)) => _set.any(test);
  List<E> toList({ bool growable: true }) => _set.toList(growable: growable);
  Set<E> toSet() => _set.toSet();
  Iterable<E> take(int n) => _set.take(n);
  Iterable<E> takeWhile(bool test(E value)) => _set.takeWhile(test);
  Iterable<E> skip(int n) => _set.skip(n);
  Iterable<E> skipWhile(bool test(E value)) => _set.skipWhile(test);
  E firstWhere(bool test(E element), { E orElse() }) => _set.firstWhere(test);
  E lastWhere(bool test(E element), {E orElse()}) => _set.lastWhere(test);
  E singleWhere(bool test(E element)) => _set.singleWhere(test);
  E elementAt(int index) => _set.elementAt(index);
}
