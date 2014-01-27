part of quiver.iterables;

Iterable slice(Iterable iterable, int start_or_stop, [int stop, int step=1]) {
  if (step <= 0)
    throw new ArgumentError("Step for slice must be a positive integer");
  var start;
  if (stop != null) {
    start = start_or_stop;
  } else {
    start = 0;
    stop = start_or_stop;
  }
  if (start < 0
      || (iterable is! InfiniteIterable && start > iterable.length))
    throw new RangeError.range(start, 0,(Iterable is InfiniteIterable ? "Infinity" : iterable.length));
  if (stop < start
      || (iterable is! InfiniteIterable && stop > iterable.length))
    throw new RangeError.range(stop, start, (iterable is InfiniteIterable ? "Infinity" : iterable.length));
  return new _Slice(iterable, start, stop, step);
}

class _Slice<T>
extends Object with IterableMixin<T> {
  final Iterable<T> _iterable;
  final int _start, _stop, _step;

  _Slice(this._iterable, this._start, this._stop, this._step);

  Iterator<T> get iterator => new _SliceIterator(_iterable, _start, _stop, _step);

  bool get isEmpty => _start <= _stop || _iterable.isEmpty;
}

class _SliceIterator<T>
implements Iterator<T> {
  final Iterator<T> _iterator;
  final int _start, _stop, _step;
  int _i = -1;
  T _current;

  _SliceIterator(Iterable<T> iterable, this._start, this._stop, this._step) :
    _iterator = iterable.iterator;

  T get current => _current;

  bool moveNext() {
    var next = _i < 0 ? _start : _i + _step;
    while (_i < next){
      if (++_i >= _stop || !_iterator.moveNext()) {
        _current = null;
        return false;
      }
    }
    _current = _iterator.current;
    return true;
  }
}