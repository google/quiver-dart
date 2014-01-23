part of quiver.collection;

class _ListNode<T> {
  LinkedList<T> _list;
  T value;
  _ListNode<T> _next;
  _ListNode<T> _prev;

  _ListNode(LinkedList<T> this._list, T this.value);

  bool get isLast => _next is _LastSentinel;
  bool get isFirst => _prev is _HeadSentinel;

  void unlink() {
    _next = null;
    _prev = null;
    _list = null;
  }

  void link(_ListNode<T> prev, _ListNode<T> next) {
    this.prev = prev;
    this.next = next;
  }

  LinkedList<T> get list => _list;

  _ListNode<T> get next => _next;
  void set next(_ListNode<T> node) {
    assert(node != null);
    this._next = node;
    node._prev = this;
  }

  _ListNode<T> get prev => _prev;
  void set prev(_ListNode<T> node) {
    assert(node != null);
    this._prev = node;
    if (node != null) {
      node._next = this;
    }
  }

  String toString() => "ListNode($value)";
}

class _HeadSentinel extends _ListNode {
  _HeadSentinel(LinkedList list) : super(list, null);

  _ListNode _next;
  get next => _next;
  set next(_ListNode node) {
    assert(node != null);
    _next = node;
    node._prev = this;
  }

  get prev => null;
  set prev(_ListNode value) {
    assert(false);
  }

  String toString() => "__HEAD__";

}

class _LastSentinel extends _ListNode {
  _LastSentinel(LinkedList list) : super(list, null);

  get prev => _prev;
  set prev(_ListNode node) {
    assert(node != null);
    _prev = node;
    node._next = this;
  }

  get next => null;
  set next(_ListNode value) {
    assert(false);
  }

  String toString() => "__LAST__";
}

/**
 * A view on a node in a list.
 */
class ListNodeView<T> {
  _ListNode<T> _node;
  bool _removed = false;

  LinkedList get list => _node.list;
  ListNodeView<T> get next {
    if (_node.isLast)
      return null;
    return new ListNodeView._(_node.next);
  }

  ListNodeView<T> get prev {
    if (_node.isFirst)
      return null;
    return new ListNodeView._(_node.prev);
  }

  T get value => _node.value;
  set value(T value) => _node.value = value;

  /**
   * Insert a value into the list after `this`
   * Throws a [StateError] if the node has previously been removed from this list.
   */
  void insertAfter(T value) {
    if (_removed) {
      throw new StateError("Cannot insert after remove node");
    }
    _node.list._insertAfter(_node, value);
  }

  /**
   * Insert a value in the list before `this`.
   * Throws a [StateError] if the node has previously been removed from the list.
   */
  void insertBefore(T value) {
    if (_removed) {
      throw new StateError("Cannot insert before removed node");
    }
    _node.list._insertAfter(_node.prev, value);
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

  ListNodeView._(_ListNode<T> this._node);
}

/**
 * A doubly linked list implementation which doesn't require nodes to extend
 * [LinkedListEntry] from the `dart:collection` library.
 */
class LinkedList<T> extends IterableBase<T> {
  _ListNode<T> _lastsentinel;
  _ListNode<T> _headsentinel;
  int _length;
  int _modificationCount;

  LinkedList() {
    _headsentinel = new _HeadSentinel(this);
    _lastsentinel = new _LastSentinel(this);
    _headsentinel.next = _lastsentinel;
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
  void add(T value) {
    _insertAfter(_lastsentinel.prev, value);
  }

  /**
   * Add all the values in the iterable to the end of the list.
   */
  void addAll(Iterable<T> values) {
    values.forEach(add);
  }

  /**
   * Add a value to the start of a list
   */
  void addFirst(T value) {
    _insertAfter(_headsentinel, value);
  }

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

  _nodeAt(int i) {
    if (i < 0 || i >= _length) {
      throw new RangeError.range(i, 0, _length - 1);
    }
    var _curr = _headsentinel;
    while (i-- >= 0 && _curr is! _LastSentinel)
      _curr = _curr.next;
    return _curr;
  }

  /**
   * Return a view on the node at the given index into the list.
   */
  ListNodeView<T> nodeAt(int i) {
    return new ListNodeView._(_nodeAt(i));
  }

  /**
   * Remove the node, given the
   */
  void remove(ListNodeView<T> node) {
    if (node._removed) {
      throw new StateError("Already removed");
    }
    node._removed = true;
    _unlink(node._node);
  }

  /**
   * Insert a value at the given index in the list.
   */
  void insert(int i, T value) {
    _insertAfter(_nodeAt(i), value);
  }

  /**
   * Insert a value after the viewed node.
   * Throws a [StateError] if the node has previously been removed from the list.
   */
  T insertAfter(ListNodeView<T> node, T value) {
    if (node._removed) {
      throw new StateError("Cannot insert after a removed node");
    }
    return _insertAfter(node._node, value);
  }

  /**
   * Insert a value before the viewed node.
   * Throws a [StateError] if the node has been removed from the list.
   */
  T insertBefore(ListNodeView<T> node, T value) {
    if (node._removed) {
      throw new StateError("Cannot insert before a removed node");
    }
    return _insertAfter(node._node._prev, value);
  }

  _insertAfter(_ListNode<T> node, T value) {
    _modificationCount++;
    var insertNode = new _ListNode<T>(this, value);
    insertNode.link(node, node.next);
    _length++;
  }

  T _unlink(_ListNode<T> node) {
    _modificationCount++;
    node._prev.next = node.next;
    node.unlink();
    _length--;
    return node.value;
  }

  void clear() {
    _modificationCount++;
    var curr = _headsentinel.next;
    assert(curr.isFirst);
    while (curr.next.isLast) {
      //unlink so GC can collect.
      var next = curr.next;
      curr.unlink();
      curr = next;
    }
    _headsentinel.next = _lastsentinel;
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
  _ListNode<T> _currNode;

  _LinkedListIterator(LinkedList<T> list) :
    _list = list,
    _currNode = list._headsentinel,
    _modificationCount = list._modificationCount;

  T get current => _currNode.value;

  bool moveNext() {
    if (_currNode is _LastSentinel)
      return false;
    if (_currNode.isLast) {
      _currNode = _currNode.next;
      return false;
    }
    if (_modificationCount != _list._modificationCount) {
      throw new ConcurrentModificationError("List changed while iterating");
    }
    _currNode = _currNode.next;
    return true;

  }
}


