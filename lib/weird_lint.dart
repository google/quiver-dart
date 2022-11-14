class Monkey<T> {
  Monkey(this._value);
  final T? _value;

  /// Transforms the Optional value.
  ///
  /// If the Optional is [absent()], returns [absent()] without applying the transformer.
  ///
  /// Returns [absent()] if the transformer returns [null].
  bool transformNullable(bool Function(T value) transformer) {
    return _value == null || transformer(_value!);
  }
}
