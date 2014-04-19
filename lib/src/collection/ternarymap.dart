// Copyright 2014 Google Inc. All Rights Reserved.
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
 * Implments a Map<String, [V]> as a Ternary Search tree. Each character in the
 * String key is stored as either less-than, equal-to, or greater-than
 * children.
 *
 * When using a TernaryMap, it is advised to insert keys in random order or
 * you could get a degenerate tree. This tree is not self balancing.
 */
class TernaryMap<V> implements Map<String, V> {
  _TernaryNode _root;
  int _count = 0;
  int _modCount = 0;

  @override
  int get length => _count;

  @override
  bool get isEmpty => _count == 0;

  @override
  bool get isNotEmpty => _count > 0;

  TernaryMap();

  /**
   * Creates a new map from [other] according to its key order.
   * Note: This could lead to an unbalanced tree if other is sorted.
   */
  TernaryMap.from(Map<String, V> other) {
    other.forEach((k,v) => this[k] = v);
  }

  TernaryMap.fromIterable(Iterable itr, {Function key, Function value}) {
    for (var obj in itr) {
      this[key == null ? obj : key(obj)] = value == null ? obj : value(obj);
    }
  }

  @override
  operator []= (String key, V value) {
    _add(key, value);
  }

  @override
  V operator [] (String key) {
    if (_count == 0) return null;
    var node = _root._lookup(key);
    return node != null && node.isValue ? node.value : null;
  }

  /**
   * Add all elements from [other] to this map according to its key order.
   * Note: This could lead to an unbalanced tree if other is sorted.
   */
  @override
  void addAll(Map<String,V> other) {
    other.forEach((k,v) => this[k] = v);
  }

  @override
  void clear() {
    _count = 0;
    _root = null;
  }

  @override
  bool containsKey(String key) {
    if (_count == 0) return false;
    var node = _root._lookup(key);
    return node != null && node.isValue;
  }

  /**
   * Tests if the [key] prefix exists, e.g. "loo" would return true if "look".
   */
  bool containsPrefix(String key) {
    if (_count == 0) return false;
    var node = _root._lookup(key);
    return node != null;
  }

  /**
   * Returns the most direct value for a prefixed [key]. If "look" was inserted
   * before "loon", this would return "look" for "loo".
   */
  V prefixPriorty(String key) {
    if (key == null || _count == 0) return null;
    var node = _root._lookup(key);
    while(node != null) {
      if (node.isValue) return node.value;
      node = node.center;
    }
    return null;
  }

  @override
  bool containsValue(V value) {
    if (_count == 0) return false;
    return _root.containsValue(value);
  }

  @override
  void forEach(void callback(k,v)) {
    if (_root == null) return;
    _root._dfs((node, [path]) {
      callback(_pathToKey(path), node.value);
    }, []);
  }

  /**
   * Depth-first search the tree, starting from optional [key].
   * This implementation lets you dive for keys, values, or both with
   * [onKey], [onValue] and [onKeyValue] respectively.
   */
  void dfs({String key, onKey(String), onValue(T), onKeyValue(String, T)}) {
    if (_count == 0) return;
    var path = [];
    var startNode;
    if (key != null) {
      startNode = _root._lookup(key, path);
      if (startNode.center == null) return;
      startNode = startNode.center;
      path.add(startNode);
    } else {
      startNode = _root;
    }

    startNode._dfs((node, [path]) {
      if (onKeyValue != null
          && true == onKeyValue(_pathToKey(path), node.value)) return true;
      if (onKey != null &&  true == onKey(_pathToKey(path))) return true;
      if (onValue != null && true == onValue(node.value)) return true;
      return false;
    }, path);
  }

  /**
   * Returns minimum and maximum depths of the subtree reached by [key]
   * or from root.
   */
  List<int> depths({String key}) {
    if (_count == 0) return [-1,-1];
    var startNode;
    if (key != null) {
      startNode = _root._lookup(key);
      if (startNode == null) return [-1,-1];
    } else {
      startNode = _root;
    }
    return startNode._depth();
  }

  @override
  Iterable<String> get keys => new _TernaryKeyIterable(this);

  @override
  V putIfAbsent(String key, V ifAbsent()) {
    return _add(key, null, ifAbsent: ifAbsent);
  }

  @override
  V remove(Object key) {
    if (key == null || _count == 0) return null;
    // Goal: Find the key. Remove its object and reset tombstone.
    // If nothing is connected underneath, remove the node.
    // Otherwise, there is room for colapsing.
    List<_TernaryNode> path = [];
    var node = _root._lookup(key, path);
    if (node == null) return null;
    var ret = node.value;
    node.value = _TernaryNode._TOMBSTONE;
    _modCount++;
    _count--;

    var last;
    // Unzip any parts that have not affect on the tree.
    while(   node.left == node.right
          && node.left == node.center
          && !node.isValue) {
      path.removeLast();
      last = node;
      if (path.length > 0) {
        node = path.last;
      } else {
        break;
      }
      if (node.left == last) {
        node.left = null;
      } else if (node.center == last) {
        node.center = null;
      } else {
        node.right = null;
      }
    }
    // TODO(jtmcdole): we can do more colapsing, but I'm not sure ternary
    // trees are generally deleted from.
    return ret;
  }

  @override
  Iterable<V> get values => new _TernaryValueIterable<V>(this);

  /**
   * Returns an iterator over the keys starting with [prefix].
   */
  Iterable<V> valuesForPrefix(String prefix) =>
      new _TernaryValueIterable<V>(this, key: prefix);

  /**
   * Returns an iterator over the keys starting with [prefix].
   */
  Iterable<V> keysForPrefix(String prefix) =>
      new _TernaryKeyIterable(this, key: prefix);

  V _add(String key, V val, {_TernaryNode current, V ifAbsent()}) {
    if (key == null || key.length == 0) return null;
    if (current == null) current = _root;
    if (_root == null) {
      _root = new _TernaryNode()
          ..key = key.codeUnitAt(0);
    }

    int index = 0;
    var units = key.codeUnits;
    current = _root;
    while(true) {
      if (units[index] == current.key) {
        index++;
        if (index == key.length) {
          if (!current.isValue) {
            _count++;
          }
          if (ifAbsent != null) {
            if (!current.isValue) {
              _modCount++;
              current.value = ifAbsent();
            }
          } else {
            _modCount++;
            current.value = val;
          }
          return current.value;
        }
        if (current.center == null) {
          current.center = new _TernaryNode()
              ..key = units[index];
        }
        current = current.center;
      } else if (units[index] < current.key) {
        if (current.left == null) {
          current.left = new _TernaryNode()
              ..key = units[index];
        }
        current = current.left;
      } else {
        if (current.right == null) {
          current.right = new _TernaryNode()
              ..key = units[index];
        }
        current = current.right;
      }
    }
  }

  static StringBuffer _sb = new StringBuffer();
  static String _pathToKey(List<_TernaryNode>path) {
    if (path == null) return "";
    _sb.clear();
    var it = path.iterator;
    it.moveNext();
    while(true) {
      var current = it.current;
      if (!it.moveNext()) {
        _sb.writeCharCode(current.key);
        break;
      }
      if (current.center == it.current) {
        _sb.writeCharCode(current.key);
      }
    }
    return _sb.toString();
  }
}


abstract class _TernaryIterable extends IterableBase<String> {

  final TernaryMap _tree;

  // Key of this iterator or null
  final String _key;

  // Root of this iterator
  final _TernaryNode _root;

  // Prefix path to _root
  final List<_TernaryNode> _path;

  _TernaryIterable(TernaryMap tree, String key)
      : _tree = tree,
        _root = (key == null || key.length == 0 || tree._count == 0)
            ? tree._root : tree._root._lookup(key).center,
        _key = (key == null || key.length == 0) ? null : key,
        _path = (key == null || key.length == 0 || tree._count == 0)
            ? [] : tree._root._lookupPath(key);

  @override
  int get length {
    if (_key == null) return _tree.length;
    return super.length;
  }
}

class _TernaryKeyIterable extends _TernaryIterable {

  _TernaryKeyIterable(TernaryMap tree, {String key}) : super(tree, key);

  @override
  bool contains(String key) {
    if (_key == null) return _tree.containsKey(key);
    if (!key.startsWith(_key)) return false;
    return _root._lookup(key.substring(_key.length)) != null;
 }

  @override
  String get first {
    if (length == 0) return null;
    var path = []..addAll(_path)..add(_root);
    _root.minNode(path);
    return TernaryMap._pathToKey(path);
  }

  @override
  String get last {
    if (length == 0) return null;
    var path = []..addAll(_path)..add(_root);
    _root.maxNode(path);
    return TernaryMap._pathToKey(path);
  }

  BidirectionalIterator<String> get iterator =>
      new _TernaryKeyIterator(_tree, key: _key, root: _root);
}

class _TernaryValueIterable<V> extends _TernaryIterable {

  _TernaryValueIterable(TernaryMap tree, {String key}) : super(tree, key);

  @override
  bool contains(V element) {
    if (_root == null) return false;
    return _root.containsValue(element);
  }

  @override
  String get first {
    if (length == 0) return null;
    var node = _root.minNode();
    return node.value;
  }

  @override
  String get last {
    if (length == 0) return null;
    var node = _root.maxNode();
    return node.value;
  }

  BidirectionalIterator<String> get iterator =>
      new _TernaryValueIterator(_tree, root: _root);
}

abstract class _TernaryMapIterator implements BidirectionalIterator<String> {
  static const LEFT = -1;
  static const WALK = 0;
  static const RIGHT = 1;

  final TernaryMap _tree;
  final _TernaryNode _root;
  final int _modCountGuard;

  int state;
  _TernaryNode _current;
  List<_TernaryNode> path = [];

  _TernaryMapIterator(TernaryMap tree, {_TernaryNode root})
      : _tree = tree,
        _root = root == null ? tree._root : root,
        _modCountGuard = tree._modCount {
    state = LEFT;
  }

  bool moveNext() {
    if (_modCountGuard != _tree._modCount) {
      throw new ConcurrentModificationError(_tree);
    }
    if (state == RIGHT || _root == null) return false;
    switch(state) {
      case LEFT:
        path.add(_root);
        _current = _root.minNode(path);
        state = WALK;
        return true;
      case WALK:
      default:
        _current = _current.successor(path);
        if (_current == null) {
          state = RIGHT;
          path = [];
        }
        return state == WALK;
    }
  }

  bool movePrevious() {
    if (_modCountGuard != _tree._modCount) {
      throw new ConcurrentModificationError(_tree);
    }
    if (state == LEFT || _tree.length == 0) return false;
    switch(state) {
      case RIGHT:
        path.add(_root);
        _current = _root.maxNode(path);
        state = WALK;
        return true;
      case WALK:
      default:
        _current = _current.predecessor(path);
        if (_current == null) {
          state = LEFT;
          path = [];
        }
        return state == WALK;
    }
  }
}

class _TernaryKeyIterator extends _TernaryMapIterator {

  String get current {
    if (state != _TernaryMapIterator.WALK
        || _current == null) return null;
    if (_key != null) {
      return "$_key${TernaryMap._pathToKey(path)}";
    }
    return TernaryMap._pathToKey(path);
  }

  final String _key;

  _TernaryKeyIterator(TernaryMap tree, {String key, _TernaryNode root} )
      : _key = key,
        super(tree, root: root);
}


class _TernaryValueIterator extends _TernaryMapIterator {

  String get current {
    if (state != _TernaryMapIterator.WALK
        || _current == null) return null;
    return _current.value;
  }

  _TernaryValueIterator(TernaryMap tree, {_TernaryNode root})
      : super(tree, root: root);
}


/**
 * Simple tombstone class that can't be inserted by users.
 */
class _TombStone {}

class _TernaryNode<V> {

  static var _TOMBSTONE = new _TombStone();

  _TernaryNode
      left,
      center,
      right;
  int key; // codeunit
  V value = _TOMBSTONE;

  bool get isValue => value != _TOMBSTONE;

  bool containsValue(V value) {
    return _dfs((val, [path]) => val.value == value);
  }

  /**
   */
  bool _dfs(bool fun(_TernaryNode node, [List<_TernaryNode> path]),
            [List<_TernaryNode> path]) {
    if (path != null) {
      path.add(this);
    }
    if (left != null && true == left._dfs(fun, path)) return true;
    if (isValue && true == fun(this, path)) return true;
    if (center != null && true == center._dfs(fun, path)) return true;
    if (right != null && true == right._dfs(fun, path)) return true;
    if (path != null) {
      path.removeLast();
    }
    return false;
  }

  List<int> _depth() {
    var path = [];
    int minDepth = -1, maxDepth = -1;
    _dfs((node, [path]) {
      if (node.left == node.right && node.center == node.left) {
        minDepth = minDepth == -1 ? path.length : min(minDepth, path.length);
        maxDepth = max(maxDepth, path.length);
      }
      return false;
    }, path);
    return <int>[minDepth, maxDepth];
  }

  _TernaryNode<V> minNode([List path]) {
    var node = this;
    while (true) {
      while (node.left != null) {
        node = node.left;
        if (path != null) path.add(node);
      }
      if (node.center != null && !node.isValue) {
        node = node.center;
        if (path != null) path.add(node);
      } else {
        return node;
      }
    }
  }

  _TernaryNode<V> maxNode([List path]) {
    var node = this;
    while (true) {
      while (node.right != null) {
        node = node.right;
        if (path != null) path.add(node);
      }
      if (node.center != null) {
        node = node.center;
        if (path != null) path.add(node);
      } else {
        return node;
      }
    }
  }

  _TernaryNode<V> successor(List<_TernaryNode> path) {
    _TernaryNode node = this;
    if (node.center != null) {
      path.add(node.center);
      return node.center.minNode(path);
    }
    if (node.right != null) {
      path.add(node.right);
      return node.right.minNode(path);
    }
    while(node != null && path.length > 1) {
      // pop'n up.
      path.removeLast();
      var last = path.last;
      if (last.right != node) {
        if (last.left == node) {
          if (last.isValue) {
            return last;
          } else if (last.center != null) {
            path.add(last.center);
            return last.center.minNode(path);//no longer last
          }
        }
        if (last.right != null) {
          path.add(last.right);
          return last.right.minNode(path);//no longer last
        }
      }
      // else pop up.
      node = last;
    }
    return null;
  }

  _TernaryNode<V> predecessor(List<_TernaryNode> path) {
    _TernaryNode node = this;
    if (node.left != null) {
      path.add(node.left);
      return node.left.maxNode(path);
    }
    while(node != null && path.length > 1) {
      // pop'n up.
      path.removeLast();
      var last = path.last;
      if (last.left != node) {
        if (last.right == node && last.center != null) {
            path.add(last.center);
            return last.center.maxNode(path);//no longer last
        } else if (last.isValue) {
          return last;
        } else if (last.left != null) {
          path.add(last.left);
          return last.left.maxNode(path);//no longer last
        }
      }
      // else pop up.
      node = last;
    }
    return null;
  }

  _TernaryNode _lookup(String key, [List<_TernaryNode> path]) {
    if (key == null || key.length == 0) return null;
    int index = 0;
    var units = key.codeUnits;
    var current = this;
    while(current != null) {
      if (path != null) path.add(current);
      if (units[index] == current.key) {
        index++;
        if (index == key.length) return current;
        current = current.center;
      } else if (units[index] < current.key) {
        current = current.left;
      } else {
        current = current.right;
      }
    }
    return null;
  }

  List<_TernaryNode> _lookupPath(String key) {
    if (key == null || key.length == 0) return [];
    int index = 0;
    var units = key.codeUnits;
    var current = this;
    var path = [];
    while(current != null) {
      path.add(current);
      if (units[index] == current.key) {
        index++;
        if (index == key.length) return path;
        current = current.center;
      } else if (units[index] < current.key) {
        current = current.left;
      } else {
        current = current.right;
      }
    }
    return [];
  }
}
