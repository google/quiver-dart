part of quiver.iterables;

typedef bool mapPred<T>(T item);
typedef S mapFunc<T, S>(T item);

/// Function executes function [func] only on element when function [pred] is true for given element.
Iterable<T> mapWhen<T>(Iterable<T> iter, mapPred<T> pred, mapFunc<T, T> func) {
  return iter.map((f) {
    if (pred(f))
      return func(f);
    else
      return f;
  });
}

typedef S mapIndexFunc<T, S>(int index, T item);

/// Executes func on each element
Iterable<S> mapIndexed<T, S>(List<T> iter, mapIndexFunc<T, S> func) sync* {
  for (var i = 0; i < iter.length; i++) {
    yield func(i, iter[i]);
  }
}

typedef S annotateFunc<T, S>(T item);

/// Returns [Iterable] of map object which contains unmodified items of keys and result of function [func]
Iterable<Map<T, S>> annotate<T, S>(
    Iterable<T> iter, annotateFunc<T, S> func) sync* {
  for (var item in iter) {
    yield <T, S>{item: func(item)};
  }
}

/// Return the concatenation of the result of mapping [func] over list.
Iterable<T> mapcat<T>(Iterable<T> iter, mapFunc<T, T> func) sync* {
  for (var item in iter) {
    yield item;
    yield func(item);
  }
}

/// Returns [Iterable] which contains elements on positions from [indexes]
Iterable<T> selectByIndex<T>(List<T> iter, List<int> indexes) sync* {
  for (var index in indexes) {
    if (index > iter.length || index < 0) continue;

    yield iter[index];
  }
}

/// Returns true if [Iterable] [iter] starts with elements from [prfix]
bool isPrefix<T>(List<T> prefix, List<T> iter) {
  int matching = 0;
  for (var i = 0; i < prefix.length; i++) {
    if (prefix[i] == iter[i]) matching++;
  }

  return matching == prefix.length;
}

/// Returns true if [Iterable] [iter] ends with elements from [prfix]
bool isSuffix<T>(List<T> suffix, List<T> iter) {
  return (isPrefix(suffix, iter.sublist(iter.length - suffix.length)));
}

/// Gets last [count] number of values from Iterable [iter]
Iterable<T> takeLast<T>(List<T> iter, int count) {
  return iter.sublist(iter.length - count);
}

/// Splits [Iterable] at position [pos]
Iterable<Iterable<T>> splitAt<T>(List<T> iter, int pos) sync* {
  yield iter.sublist(0, pos);
  yield iter.sublist(pos);
}

/// Splits [Iterable] [iter] based on function [func].
/// If [func] returns true elemnt is added to first list, otherwise to second.
/// Function returns Iterable with two other iterables.
Iterable<Iterable<T>> splitWith<T>(List<T> iter, mapPred<T> func) {
  List<T> one = List();
  List<T> two = List();

  for (var item in iter) {
    if (func(item))
      one.add(item);
    else
      two.add(item);
  }

  return [one, two];
}
