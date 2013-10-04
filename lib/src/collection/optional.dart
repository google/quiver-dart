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

  factory Optional.absent() => new Optional<T>.fromNullable(null);

  Optional.of(this._value) {
    if (this._value == null) throw new ArgumentError('Must not be null.');
  }

  Optional.fromNullable(this._value);

  bool get isPresent => _value != null;

  T get get {
    if (this._value == null) throw new StateError('get called on absent Optional.');
    return _value;
  }

  T or(T defaultValue) {
    if (defaultValue == null) throw new ArgumentError('defaultValue must not be null.');
    return _value == null ? defaultValue : _value;
  }

  T get orNull => _value;

  Set<T> get asSet =>
    _value == null ? new Set<T>() : new Set<T>.from([_value]);

  Optional transform(Function function) {
    return _value == null
        ? new Optional<T>.absent()
        : new Optional<T>.of(function(_value));
  }

  int get hashCode => _value.hashCode;

  bool operator==(o) => o is Optional && o._value == _value;

  String toString() {
    return _value == null
        ? 'Optional.absent()'
        : 'Optional<${_value.runtimeType.toString()}>.of(${_value})';
  }
}
