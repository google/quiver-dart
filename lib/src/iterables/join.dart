part of quiver.iterables;

/**
 * Matches all elements of the [:innerIterable:] to those elements of the
 * [:outerIterable:] for which the function [:on:] returns `true`.
 *
 * This function can be considered to provide a superset of [innerJoin] and [leftOuterJoin]
 * functionality.
 */
Iterable<GroupJoinRow> groupJoin(Iterable innerIterable,
                                 Iterable outerIterable,
                                 { bool on(innerElement, outerElement) }) {
  if (on == null)
    on = (x,y) => x == y;
  return new _GroupJoin(innerIterable, outerIterable, on);
}

class GroupJoinRow<K,V> extends IterableBase<V> {
  final K inner;
  final Iterable<V> outer;

  Iterator<V> get iterator => outer.iterator;

  GroupJoinRow(this.inner, this.outer);
}

/**
 * An [:innerJoin:] performs an *SQL* style `INNER JOIN` operation on
 * two iterables, returning an [Iterable] of [InnerJoinReult]s which
 * contains all pairs of values in both iterables which agree on the
 * given key functions.
 */
Iterable<InnerJoinRow> innerJoin(Iterable innerIterable,
                                    Iterable outerIterable,
                                    { bool on(innerElement, outerElement) })
    => groupJoin(innerIterable, outerIterable, on: on)
          .where((grp) => grp.outer.isNotEmpty)
          .expand((grp) => grp.outer.map((v) => new InnerJoinRow(grp.inner, v)));

class InnerJoinRow<E1,E2> {
  final E1 left;
  final E2 right;

  InnerJoinRow(this.left, this.right);

  bool operator ==(Object other) =>
      other is InnerJoinRow && left == other.left && right == other.right;

  int get hashCode =>
      ((left.hashCode * 37) + right.hashCode) * 37;

  String toString() => "InnerJoinResult($left, $right)";
}

/**
 * [:leftOuterJoin:] performs an *SQL* style `LEFT OUTER JOIN` operation on
 * the elements of the two iterables, returning an [Iterable] of [OuterJoinRow]
 * instances.
 *
 * The outer value is an [Optional] value, which is present only if the matched
 * outer value is not `null`, or if there were no results matched by the [:on:]
 * function against the inner iterable.
 *
 * Special care should be taken to ensure that outer iterables which could possibly
 * contain `null` values are not misinterpreted as missing elements in the result.
 */
Iterable<OuterJoinRow> leftOuterJoin(Iterable innerIterable,
                                        Iterable outerIterable,
                                        { bool on(innerElement, outerElement)})
    => groupJoin(innerIterable, outerIterable, on: on)
          .expand((grp) {
            if (grp.isEmpty) {
              return [ new OuterJoinRow(grp.inner, new Optional.absent()) ];
            } else {
              return grp.outer.map((outer) => new OuterJoinRow(grp.inner, new Optional.fromNullable(outer)));
            }
          });

class OuterJoinRow<E1,E2> {
  final E1 inner;
  final Optional<E2> outer;

  OuterJoinRow(E1 this.inner, E2 this.outer);

  bool operator ==(Object other) =>
      other is OuterJoinRow
      && other.inner == inner
      && other.outer == outer;

  int get hashCode =>
      ((inner.hashCode * 31) + inner.hashCode) * 31;

  String toString() => "OuterJoinResult($inner, $outer)";
}

typedef bool Predicate<E1,E2>(E1 innervalue, E2 outerValue);

class _GroupJoin<E1,E2> extends IterableBase<GroupJoinRow<E1,E2>> {
  final Iterable<E1> _innerIterable;
  final Iterable<E2> _outerIterable;
  final Predicate<E1,E2> _on;

  _GroupJoin(Iterable<E1> this._innerIterable,
             Iterable<E2> this._outerIterable,
             bool this._on(E1 innerElement, E2 outerElement));

  Iterator<GroupJoinRow<E1,E2>> get iterator =>
     new _GroupJoinIterator(_innerIterable, _outerIterable, _on);
}

class _GroupJoinIterator<E1,E2> implements Iterator<GroupJoinRow<E1,E2>> {
  final Iterator<E1> _innerIterator;
  final Iterable<E2> _outerIterable;

  final Predicate<E1,E2> _on;
  GroupJoinRow<E1,E2> _current;

  _GroupJoinIterator(innerIterable, this._outerIterable, this._on) :
    _innerIterator = innerIterable.iterator,
    _current = null;

  GroupJoinRow<E1,E2> get current => _current;

  bool moveNext() {
    bool hasNext = _innerIterator.moveNext();
    if (hasNext) {
      var key = _innerIterator.current;
      _current =
          new GroupJoinRow(key, _outerIterable.where((v) => _on(key, v)));
    } else {
      _current = null;
    }
    return hasNext;
  }
}