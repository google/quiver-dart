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
 * A value that might be absent.
 *
 * Use Optional as an alternative to allowing fields, parameters or return
 * values to be null. It signals that a value is not required and provides
 * convenience methods for dealing with the absent case.
 */
class Optional<T> {
  final T _value;

  /**
   * Constructs an empty Optional.
   */
  const Optional.absent() : _value = null;

  /**
   * Constructs an Optional of the given [_value].
   *
   * Throws [ArgumentError] if [_value] is null.
   */
  Optional.of(this._value) {
    if (this._value == null) throw new ArgumentError('Must not be null.');
  }

  /**
   * Constructs an Optional of the given [_value].
   *
   * If [_value] is null, returns [absent()].
   */
  const Optional.fromNullable(this._value);

  /**
   * Whether the Optional contains a value.
   */
  bool get isPresent => _value != null;

  /**
   * Gets the Optional value.
   *
   * Throws [StateError] if [_value] is null.
   */
  T get value {
    if (this._value == null) throw new StateError('get called on absent Optional.');
    return _value;
  }

  /**
   * Executes a function if the Optional value is present.
   */
  void ifPresent(void ifPresent(T value)) {
    if (isPresent) {
      ifPresent(_value);
    }
  }

  /**
   * Execution a function if the Optional value is absent.
   */
  void ifAbsent(void ifAbsent()) {
    if (!isPresent) {
      ifAbsent();
    }
  }

  /**
   * Gets the Optional value with a default.
   *
   * The default is returned if the Optional is [absent()].
   *
   * Throws [ArgumentError] if [defaultValue] is null.
   */
  T or(T defaultValue) {
    if (defaultValue == null) throw new ArgumentError('defaultValue must not be null.');
    return _value == null ? defaultValue : _value;
  }

  /**
   * Gets the Optional value, or [null] if there us none.
   */
  T get orNull => _value;

  /**
   * Gets the Optional value as a Set.
   *
   * The Set has exactly one or zero elements.
   */
  Set<T> get asSet =>
    _value == null ? new Set<T>() : new Set.from([_value]);

  /**
   * Transforms the Optional value.
   *
   * If the Optional is [absent()], returns [absent()] without applying the transformer.
   *
   * The transformer must not return [null]. If it does, an [ArgumentError] is thrown.
   */
  Optional transform(T transformer(T value)) {
    return _value == null
        ? new Optional<T>.absent()
        : new Optional<T>.of(transformer(_value));
  }

  /**
   * Delegates to the underlying [_value] hashCode.
   */
  int get hashCode => _value.hashCode;

  /**
   * Delegates to the underlying [_value] operator==.
   */
  bool operator==(o) => o is Optional && o._value == _value;

  String toString() {
    return _value == null
        ? 'Optional { absent }'
        : 'Optional { value: ${_value} }';
  }
}
