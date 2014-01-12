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
 *                      on: (dept, emp) => dept.name == emp.departmentName);
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
                          { bool on(innerElement, outerElement) }) {
  if (on == null)
    on = (x,y) => x == y;
  return new _GroupJoin(innerIterable, outerIterable, on);
}

/**
 * An [:innerJoin:] performs an *SQL* style `INNER JOIN` operation on
 * two iterables, returning an [Iterable] of [InnerJoinReult]s which
 * contains all pairs of values in both iterables which agree on the
 * given key functions.
 */
Iterable<InnerJoinResult> innerJoin(Iterable innerIterable,
                                    Iterable outerIterable,
                                    { bool on(innerElement, outerElement) }) {
  var grpJoin = groupJoin(innerIterable, outerIterable, on: on);
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
                                        { bool on(innerElement, outerElement)}) {
  var grpJoin = groupJoin(innerIterable, outerIterable, on: on);
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

typedef bool Predicate<E1,E2>(E1 innervalue, E2 outerValue);

class _GroupJoin<E1,E2>
extends Object with IterableMixin<Group<E1,E2>> {
  final Iterable<E1> _innerIterable;
  final Iterable<E2> _outerIterable;
  final Predicate<E1,E2> _on;

  _GroupJoin(Iterable<E1> this._innerIterable,
             Iterable<E2> this._outerIterable,
             bool this._on(E1 innerElement, E2 outerElement));

  Iterator<Group<E1,E2>> get iterator =>
     new _GroupJoinIterator(_innerIterable, _outerIterable, _on);
}

class _GroupJoinIterator<E1,E2> implements Iterator<Group<E1,E2>> {
  final Iterator<E1> _innerIterator;
  final Iterable<E2> _outerIterable;

  final Predicate<E1,E2> _on;
  Group<E1,E2> _current;

  _GroupJoinIterator(innerIterable, this._outerIterable, this._on) :
    _innerIterator = innerIterable.iterator,
    _current = null;

  Group<E1,E2> get current => _current;

  bool moveNext() {
    bool hasNext = _innerIterator.moveNext();
    if (hasNext) {
      var key = _innerIterator.current;
      _current =
          new Group(key, _outerIterable.where((v) => _on(key, v)));
    } else {
      _current = null;
    }
    return hasNext;
  }
}