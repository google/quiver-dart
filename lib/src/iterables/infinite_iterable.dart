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

part of quiver.iterables;

/// A base class for [Iterable]s of infinite length that throws
/// [UnsupportedError] for methods that would require the Iterable to
/// terminate.
abstract class InfiniteIterable<T> extends IterableBase<T> {
  bool get isEmpty => false;

  bool get isNotEmpty => true;

  T get last => throw new UnsupportedError('last');

  int get length => throw new UnsupportedError('length');

  T get single => throw new StateError('single');

  bool every(bool f(T element)) => throw new UnsupportedError('every');

  T1 fold<T1>(T1 initialValue, T1 combine(T1 previousValue, T element)) =>
      throw new UnsupportedError('fold');

  void forEach(void f(T element)) => throw new UnsupportedError('forEach');

  String join([String separator = '']) => throw new UnsupportedError('join');

  T lastWhere(bool test(T value), {T orElse()}) =>
      throw new UnsupportedError('lastWhere');

  T reduce(T combine(T value, T element)) =>
      throw new UnsupportedError('reduce');

  List<T> toList({bool growable: true}) => throw new UnsupportedError('toList');

  Set<T> toSet() => throw new UnsupportedError('toSet');
}
