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

part of quiver.core;

/// A value that might be absent.
///
/// Use Optional as an alternative to allowing fields, parameters or return
/// values to be null. It signals that a value is not required and provides
/// convenience methods for dealing with the absent case.
class Optional<T> extends IterableBase<T> {
  final T _value;

  /// Constructs an empty Optional.
  const Optional.absent() : _value = null;

  /// Constructs an Optional of the given [value].
  ///
  /// Throws [ArgumentError] if [value] is null.
  Optional.of(T value) : this._value = value {
    if (this._value == null) throw new ArgumentError('Must not be null.');
  }

  /// Constructs an Optional of the given [value].
  ///
  /// If [value] is null, returns [absent()].
  const Optional.fromNullable(T value) : this._value = value;

  /// Whether the Optional contains a value.
  bool get isPresent => _value != null;

  /// Gets the Optional value.
  ///
  /// Throws [StateError] if [value] is null.
  T get value {
    if (this._value == null) {
      throw new StateError('value called on absent Optional.');
    }
    return _value;
  }

  /// Executes a function if the Optional value is present.
  void ifPresent(void ifPresent(T value)) {
    if (isPresent) {
      ifPresent(_value);
    }
  }

  /// Execution a function if the Optional value is absent.
  void ifAbsent(void ifAbsent()) {
    if (!isPresent) {
      ifAbsent();
    }
  }

  /// Gets the Optional value with a default.
  ///
  /// The default is returned if the Optional is [absent()].
  ///
  /// Throws [ArgumentError] if [defaultValue] is null.
  T or(T defaultValue) {
    if (defaultValue == null) {
      throw new ArgumentError('defaultValue must not be null.');
    }
    return _value == null ? defaultValue : _value;
  }

  /// Gets the Optional value, or [null] if there is none.
  T get orNull => _value;

  /// Transforms the Optional value.
  ///
  /// If the Optional is [absent()], returns [absent()] without applying the transformer.
  ///
  /// The transformer must not return [null]. If it does, an [ArgumentError] is thrown.
  Optional/*=Optional<S>*/ transform/*<S>*/(
      dynamic/*=S*/ transformer(T value)) {
    return _value == null
        ? new Optional.absent()
        : new Optional.of(transformer(_value));
  }

  @override
  Iterator<T> get iterator =>
    isPresent ? <T>[_value].iterator : new Iterable<T>.empty().iterator;

  /// Delegates to the underlying [value] hashCode.
  int get hashCode => _value.hashCode;

  /// Delegates to the underlying [value] operator==.
  bool operator ==(o) => o is Optional && o._value == _value;

  String toString() {
    return _value == null
        ? 'Optional { absent }'
        : 'Optional { value: ${_value} }';
  }
}
