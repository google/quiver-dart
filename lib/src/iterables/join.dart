part of quiver.iterables;

/**
 * Performs an *SQL* style join operation on the two iterables,
 * returning the result as an iterable of [Group]s, such that
 * values from the inner iterable are matched against all values
 * of the outer iterable which agree on the respective key functions.
 *
 * eg.
 *      class Employee {
 *          String lastName;
 *          String departmentName;
 *
 *          Employee(this.lastName, departmentName);
 *      }
 *
 *      class Department {
 *        String name;
 *        String departmentContact;
 *
 *        Department(this.name, this.phoneNumber);
 *      }
 *
 *      var employees =
 *          [ new Employee("Smith", "marketing"),
 *            new Employee("Johannes", "sales"),
 *            new Employee("Jones", "marketing"),
 *            new Employee("Leith", "marketing"),
 *            new Employee("Killjoy", "sales"),
 *            new Employee("Jackson", "HR")
 *          ];
 *
 *      var departments =
 *          [ new Department("sales", "043-444-456"),
 *            new Department("marketing", "032-444-444"),
 *            new Department("HR", "555-555-555")
 *          ];
 *
 *      void main() {
 *        var employeeHeads =
 *            groupJoin(departments, employees,
 *                      innerKey: (dpt) => dpt.name,
 *                      outerKey: (emp) => emp.departmentName);
 *        for (var grp in employeeHeads) {
 *          print("${grp.key.name} (Ph: ${grp.key.contact})");
 *          for (var emp in grp) {
 *            print("\t${emp.lastName});
 *        }
 *      }
 *
 * would print
 *
 *      sales (Ph: 043-444-456)
 *          Johannes
 *          Killjoy
 *      marketing (Ph: 032-444-444)
 *          Smith
 *          Jones
 *          Leith
 *      HR (Ph: 555-555-555)
 *          Jackson
 */
Iterable<Group> groupJoin(Iterable innerIterable,
                          Iterable outerIterable,
                          { dynamic innerKey(var value),
                            dynamic outerKey(var value)
                          }) {
  if (innerKey == null)
    innerKey = (x) => x;
  if (outerKey == null)
    outerKey = (x) => x;
  return new _GroupJoin(innerIterable, outerIterable, innerKey, outerKey);
}

/**
 * An [:innerJoin:] performs an *SQL* style `INNER JOIN` operation on
 * two iterables, returning an [Iterable] of [InnerJoinReult]s which
 * contains all pairs of values in both iterables which agree on the
 * given key functions.
 */
Iterable<InnerJoinResult> innerJoin(Iterable innerIterable,
                                    Iterable outerIterable,
                                    { dynamic innerKey(var value),
                                      dynamic outerKey(var value)
                                    }) {
  var grpJoin = groupJoin(innerIterable, outerIterable, innerKey: innerKey, outerKey: outerKey);
  return grpJoin
      .where((grp) => grp.values.isNotEmpty)
      .expand((grp) => grp.values.map((v) => new InnerJoinResult(grp.key, v)));
}

class InnerJoinResult<E1,E2> {
  final E1 left;
  final E2 right;

  InnerJoinResult(this.left, this.right);

  bool operator ==(Object other) =>
      other is InnerJoinResult && left == other.left && right == other.right;

  int get hashCode =>
      ((left.hashCode * 37) + right.hashCode) * 37;

  String toString() => "InnerJoinResult($left, $right)";
}

/**
 * [:leftOuterJoin:] performs an *SQL* style `LEFT OUTER JOIN` operation on
 * the elements of the two iterables, returning an [Iterable] of [OuterJoinResult]
 * instances.
 *
 * If a given element of the inner iterable has no corresponding elements in the
 * outer iterable or if the matched outerIterable element is `null`, the resulting
 * [OuterJoinResult] will have be absent.
 */
Iterable<OuterJoinResult> leftOuterJoin(Iterable innerIterable,
                                        Iterable outerIterable,
                                        { dynamic innerKey(var value),
                                          dynamic outerKey(var value)
                                        }) {
  var grpJoin = groupJoin(innerIterable, outerIterable, innerKey: innerKey, outerKey: outerKey);
  return grpJoin
      .expand((grp) {
        if (grp.values.isEmpty) {
          return [ new OuterJoinResult(grp.key, new Optional.absent()) ];
        } else {
          return grp.values.map((v) => new OuterJoinResult(grp.key, new Optional.fromNullable(v)));
        }
      });
}

class OuterJoinResult<E1,E2> {
  final E1 left;
  final Optional<E2> right;
  OuterJoinResult(this.left, this.right);

  bool operator ==(Object other) =>
      other is OuterJoinResult && other.left == left && other.right == right;

  int get hashCode =>
      ((left.hashCode * 31) + right.hashCode) * 31;

  String toString() => "OuterJoinResult($left, $right)";
}

class _GroupJoin<E1,E2,K>
extends Object with IterableMixin<Group<E1,E2>> {
  final List<_Tuple<K,E1>> _innerKeyedIterable;
  final Iterable<_Tuple<K,E2>> _outerKeyedIterable;

  _GroupJoin(Iterable<E1> innerIterable,
             Iterable<E2> outerIterable,
             K innerKey(E1 innerElement),
             K outerKey(E2 innerElement)) :
    _innerKeyedIterable = new List.from(new _TupleZip(innerIterable.map(innerKey),
                                                      innerIterable),
                                        growable: false),
    _outerKeyedIterable = new _TupleZip(outerIterable.map(outerKey),
                                        outerIterable);

  Iterator<Group<E1,E2>> get iterator =>
      new _GroupJoinIterator(_innerKeyedIterable, _outerKeyedIterable);
}

class _GroupJoinIterator<E1,E2,K> implements Iterator<Group<E1,E2>> {
  final List<_Tuple<K,E1>> _innerKeyedIterable;
  final Iterable<_Tuple<K,E2>> _outerKeyedIterable;

  int _keyIdx;
  Set<K> _seenKeys;
  Group<E1,E2> _current;

  _GroupJoinIterator(this._innerKeyedIterable, this._outerKeyedIterable) :
    _seenKeys = new Set<K>(),
    _keyIdx = -1,
    _current = null;

  Group<E1,E2> get current => _current;

  bool moveNext() {
    var keyPair;
    while (++_keyIdx < _innerKeyedIterable.length) {
      keyPair = _innerKeyedIterable[_keyIdx];
      if (!_seenKeys.contains(keyPair.$1)) {
        break;
      }
    }
    if (keyPair == null) {
      _current = null;
      return false;
    }
    var grpKey = keyPair.$2;
    var grpValues = _outerKeyedIterable
        .where((p) => p.$1 == keyPair.$1)
        .map((p) => p.$2);
    _current = new Group(grpKey, grpValues);
    return true;
  }
}