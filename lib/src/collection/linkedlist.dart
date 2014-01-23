part of quiver.collection;

class ListNode<T> {
  bool _removed = false;
  LinkedList<T> _list;
  T value;
  ListNode<T> _next;
  ListNode<T> _prev;

  ListNode(LinkedList<T> this._list, T this.value);

  bool get isLast => _next is _ListSentinel;
  bool get isFirst => _prev is _ListSentinel;

  void _unlink() {
    _next = null;
    _prev = null;
    _list = null;
  }

  void _link(ListNode prev, ListNode next) {
    assert(prev != null);
    assert(next != null);
    prev._next = this;
    this._prev = prev;
    next._prev = this;
    this._next = next;
  }

  /**
   * Insert a value into the list after `this`
   * Throws a [StateError] if the node has previously been removed from this list.
   */
  void insertAfter(T value) {
    if (_removed) {
      throw new StateError("Cannot insert after remove node");
    }
    list._insertAfter(this, value);
  }

  /**
   * Insert a value in the list before `this`.
   * Throws a [StateError] if the node has previously been removed from the list.
   */
  void insertBefore(T value) {
    if (_removed) {
      throw new StateError("Cannot insert before removed node");
    }
    list._insertAfter(prev, value);
  }

  /**
   * Remove the viewed node from it's list.
   * Throws a [StateError] if the node has previously been removed from the list.
   */
  void remove() {
    if (_removed) {
      throw new StateError("Already removed");
    }
    list.remove(this);
  }

  LinkedList<T> get list => _list;

  /**
   * The next node in the list
   */
  ListNode<T> get next => isLast ? null : _next;
  /**
   * The previous node in the list
   */
  ListNode<T> get prev => isFirst ? null : _prev;

  bool operator ==(Object other) => other is ListNode && other.value == value;
  int get hashCode => value.hashCode;

  String toString() => "ListNode($value)";
}

class _ListSentinel implements ListNode {
  bool _removed = false;
  Object value = null;

  LinkedList _list;
  ListNode _prev;
  ListNode _next;
  _ListSentinel(LinkedList this._list);

  LinkedList get list => _list;

  ListNode get prev => _prev;
  ListNode get next => _next;

  bool get isLast => _next is _ListSentinel;
  bool get isFirst => _prev is _ListSentinel;

  bool operator ==(Object other) =>
      other is _ListSentinel
      && other.prev == prev
      && other.next == next;

  //Should not be able to call any of these methods
  insertBefore(var value) =>throw new AssertionError();
  insertAfter(var value) => throw new AssertionError();
  remove() => throw new AssertionError();
  void _unlink() => throw new AssertionError();
  void _link(ListNode next, ListNode prev) => throw new AssertionError();


  String toString() => _prev == null ? "__HEAD__" : "__LAST__";
}

/**
 * A doubly linked list implementation which doesn't require nodes to extend
 * [LinkedListEntry] from the `dart:collection` library.
 */
class LinkedList<T> extends IterableBase<T> {
  ListNode<T> _headsentinel;
  ListNode<T> _lastsentinel;

  int _length;
  int _modificationCount;

  LinkedList() {
    _headsentinel = new _ListSentinel(this);
    _lastsentinel = new _ListSentinel(this);
    _lastsentinel._prev = _headsentinel;
    _headsentinel._next = _lastsentinel;
    _length = 0;
    _modificationCount = 0;
  }

  factory LinkedList.from(Iterable<T> iterable) {
    LinkedList li = new LinkedList();
    li.addAll(iterable);
    return li;
  }

  Iterator<T> get iterator => new _LinkedListIterator(this);

  /**
   * Add a value to the end of the list.
   */
  void add(T value) => _insertAfter(_lastsentinel.prev, value);

  /**
   * Add all the values in the iterable to the end of the list.
   */
  void addAll(Iterable<T> values) => values.forEach(add);

  /**
   * Add a value to the start of a list
   */
  void addFirst(T value) => _insertAfter(_headsentinel, value);

  /**
   * Remove the value at the head of the list and return its value.
   * Throws a [StateError] if the list is empty.
   */
  T removeFirst() {
    if (_lastsentinel.isFirst)
      throw new StateError("No elements");
    return _unlink(_headsentinel.next);
  }

  /**
   * Remove the last element in the list and return its value.
   * Throws a [StateError] if the list is empty.
   */
  T removeLast() {
    if (_headsentinel.isLast)
      return throw new StateError("No elements");
    return _unlink(_lastsentinel.prev);
  }

  /**
   * Return a view on the node at the given index into the list.
   */
  ListNode<T> nodeAt(int i) {
    if (i < 0 || i >= _length) {
      throw new RangeError.range(i, 0, _length - 1);
    }
    var _curr = _headsentinel;
    while (i-- >= 0 && _curr != _lastsentinel)
      _curr = _curr._next;
    return _curr;
  }

  /**
   * Remove the node, given the
   */
  void remove(ListNode<T> node) {
    if (node._removed) {
      throw new StateError("Already removed");
    }
    node._removed = true;
    _unlink(node);
  }

  /**
   * Insert a value at the given index in the list.
   */
  void insert(int i, T value) {
    _insertAfter(nodeAt(i), value);
  }

  /**
   * Insert a value after the viewed node.
   * Throws a [StateError] if the node has previously been removed from the list.
   */
  T insertAfter(ListNode<T> node, T value) {
    if (node._removed) {
      throw new StateError("Cannot insert after a removed node");
    }
    return _insertAfter(node, value);
  }

  /**
   * Insert a value before the viewed node.
   * Throws a [StateError] if the node has been removed from the list.
   */
  T insertBefore(ListNode<T> node, T value) {
    if (node._removed) {
      throw new StateError("Cannot insert before a removed node");
    }
    return _insertAfter(node._prev, value);
  }

  _insertAfter(ListNode<T> node, T value) {
    _modificationCount++;
    var insertNode = new ListNode<T>(this, value);
    insertNode._link(node, node._next);
    _length++;
  }

  T _unlink(ListNode<T> node) {
    _modificationCount++;
    node._prev._next = node._next;
    node._unlink();
    _length--;
    return node.value;
  }

  void clear() {
    _modificationCount++;
    var curr = _headsentinel._next;
    assert(curr.isFirst);
    while (!curr._next.isLast) {
      //unlink so GC can collect.
      var next = curr.next;
      curr._unlink();
      curr = next;
    }
    _headsentinel._next = _lastsentinel;
    _length = 0;
  }

  bool get isEmpty => _headsentinel.isLast;

  T get first {
    if (_lastsentinel.isFirst) {
      throw new StateError("No elements");
    }
    return _headsentinel.next.value;
  }

  T get last {
    if (_headsentinel.isLast) {
      throw new StateError("No elements");
    }
    return _lastsentinel.prev.value;
  }

  T get single {
    if (_headsentinel.isLast) {
      throw new StateError("No elements");
    }
    if (_length > 1) {
      throw new StateError("Too many elements");
    }
    return _headsentinel.next.value;
  }
}

class _LinkedListIterator<T> implements Iterator<T> {
  LinkedList<T> _list;
  int _modificationCount;
  ListNode<T> _currNode;

  _LinkedListIterator(LinkedList<T> list) :
    _list = list,
    _currNode = list._headsentinel,
    _modificationCount = list._modificationCount;

  T get current => _currNode.value;

  bool moveNext() {
    if (_currNode == _list._lastsentinel)
      return false;
    if (_currNode.isLast) {
      _currNode = _currNode._next;
      return false;
    }
    if (_modificationCount != _list._modificationCount) {
      throw new ConcurrentModificationError("List changed while iterating");
    }
    _currNode = _currNode._next;
    return true;

  }
}


