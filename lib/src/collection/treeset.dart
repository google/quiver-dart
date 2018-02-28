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

/// A [Set] of items stored in a binary tree according to [comparator].
/// Supports bidirectional iteration.
abstract class TreeSet<V> extends IterableBase<V> implements Set<V> {
  final Comparator<V> comparator;

  int get length;

  /// Create a new [TreeSet] with an ordering defined by [comparator] or the
  /// default `(a, b) => a.compareTo(b)`.
  factory TreeSet({Comparator<V> comparator}) {
    comparator ??= (a, b) => (a as dynamic).compareTo(b);
    return new AvlTreeSet(comparator: comparator);
  }

  TreeSet._(this.comparator);

  /// Returns an [BidirectionalIterator] that iterates over this tree.
  BidirectionalIterator<V> get iterator;

  /// Returns an [BidirectionalIterator] that iterates over this tree, in
  /// reverse.
  BidirectionalIterator<V> get reverseIterator;

  /// Returns an [BidirectionalIterator] that starts at [anchor].  By default,
  /// the iterator includes the anchor with the first movement; set [inclusive]
  /// to false if you want to exclude the anchor. Set [reversed] to true to
  /// change the direction of of moveNext and movePrevious.
  ///
  /// Note: This iterator allows you to walk the entire set. It does not
  /// present a subview.
  BidirectionalIterator<V> fromIterator(V anchor,
      {bool reversed: false, bool inclusive: true});

  /// Search the tree for the matching [object] or the [nearestOption]
  /// if missing.  See [TreeSearch].
  V nearest(V object, {TreeSearch nearestOption: TreeSearch.NEAREST});

  @override
  // ignore: override_on_non_overriding_method
  Set<T> cast<T>();

  @override
  // ignore: override_on_non_overriding_method
  Set<T> retype<T>();

  // TODO: toString or not toString, that is the question.
}

/// Controls the results for [TreeSet.searchNearest]()
enum TreeSearch {
  /// If result not found, always chose the smaller element
  LESS_THAN,

  /// If result not found, chose the nearest based on comparison
  NEAREST,

  /// If result not found, always chose the greater element
  GREATER_THAN
}

/// A node in the [TreeSet].
abstract class _TreeNode<V> {
  _TreeNode<V> get left;
  _TreeNode<V> get right;

  //TODO(codefu): Remove need for [parent]; this is just an implementation note
  _TreeNode<V> get parent;
  V object;

  /// TreeNodes are always allocated as leafs.
  _TreeNode({this.object});

  /// Return the minimum node for the subtree
  _TreeNode<V> get minimumNode {
    var node = this;
    while (node.left != null) {
      node = node.left;
    }
    return node;
  }

  /// Return the maximum node for the subtree
  _TreeNode<V> get maximumNode {
    var node = this;
    while (node.right != null) {
      node = node.right;
    }
    return node;
  }

  /// Return the next greatest element (or null)
  _TreeNode<V> get successor {
    var node = this;
    if (node.right != null) {
      return node.right.minimumNode;
    }
    while (node.parent != null && node == node.parent.right) {
      node = node.parent;
    }
    return node.parent;
  }

  /// Return the next smaller element (or null)
  _TreeNode<V> get predecessor {
    var node = this;
    if (node.left != null) {
      return node.left.maximumNode;
    }
    while (node.parent != null && node.parent.left == node) {
      node = node.parent;
    }
    return node.parent;
  }
}

/// AVL implementation of a self-balancing binary tree. Optimized for lookup
/// operations.
///
/// Notes: Adapted from "Introduction to Algorithms", second edition,
///        by Thomas H. Cormen, Charles E. Leiserson,
///           Ronald L. Rivest, Clifford Stein.
///        chapter 13.2
class AvlTreeSet<V> extends TreeSet<V> {
  int _length = 0;
  AvlNode<V> _root;
  // Modification count to the tree, monotonically increasing
  int _modCount = 0;

  int get length => _length;

  AvlTreeSet({Comparator<V> comparator}) : super._(comparator);

  /// Add the element to the tree.
  bool add(V element) {
    if (_root == null) {
      AvlNode<V> node = new AvlNode<V>(object: element);
      _root = node;
      ++_length;
      ++_modCount;
      return true;
    }

    AvlNode<V> x = _root;
    while (true) {
      int compare = comparator(element, x.object);
      if (compare == 0) {
        return false;
      } else if (compare < 0) {
        if (x._left == null) {
          AvlNode<V> node = new AvlNode<V>(object: element).._parent = x;
          x
            .._left = node
            .._balanceFactor -= 1;
          break;
        }
        x = x.left;
      } else {
        if (x._right == null) {
          AvlNode<V> node = new AvlNode<V>(object: element).._parent = x;
          x
            .._right = node
            .._balanceFactor += 1;
          break;
        }
        x = x.right;
      }
    }

    ++_modCount;

    // AVL balancing act (for height balanced trees)
    // Now that we've inserted, we've unbalanced some trees, we need
    //  to follow the tree back up to the _root double checking that the tree
    //  is still balanced and _maybe_ perform a single or double rotation.
    //  Note: Left additions == -1, Right additions == +1
    //  Balanced Node = { -1, 0, 1 }, out of balance = { -2, 2 }
    //  Single rotation when Parent & Child share signed balance,
    //  Double rotation when sign differs!
    AvlNode<V> node = x;
    while (node._balanceFactor != 0 && node.parent != null) {
      // Find out which side of the parent we're on
      if (node.parent._left == node) {
        node.parent._balanceFactor -= 1;
      } else {
        node.parent._balanceFactor += 1;
      }

      node = node.parent;
      if (node._balanceFactor == 2) {
        // Heavy on the right side - Test for which rotation to perform
        if (node.right._balanceFactor == 1) {
          // Single (left) rotation; this will balance everything to zero
          _rotateLeft(node);
          node._balanceFactor = node.parent._balanceFactor = 0;
          node = node.parent;
        } else {
          // Double (Right/Left) rotation
          // node will now be old node.right.left
          _rotateRightLeft(node);
          node = node.parent; // Update to new parent (old grandchild)
          if (node._balanceFactor == 1) {
            node.right._balanceFactor = 0;
            node.left._balanceFactor = -1;
          } else if (node._balanceFactor == 0) {
            node.right._balanceFactor = 0;
            node.left._balanceFactor = 0;
          } else {
            node.right._balanceFactor = 1;
            node.left._balanceFactor = 0;
          }
          node._balanceFactor = 0;
        }
        break; // out of loop, we're balanced
      } else if (node._balanceFactor == -2) {
        // Heavy on the left side - Test for which rotation to perform
        if (node.left._balanceFactor == -1) {
          _rotateRight(node);
          node._balanceFactor = node.parent._balanceFactor = 0;
          node = node.parent;
        } else {
          // Double (Left/Right) rotation
          // node will now be old node.left.right
          _rotateLeftRight(node);
          node = node.parent;
          if (node._balanceFactor == -1) {
            node.right._balanceFactor = 1;
            node.left._balanceFactor = 0;
          } else if (node._balanceFactor == 0) {
            node.right._balanceFactor = 0;
            node.left._balanceFactor = 0;
          } else {
            node.right._balanceFactor = 0;
            node.left._balanceFactor = -1;
          }
          node._balanceFactor = 0;
        }
        break; // out of loop, we're balanced
      }
    } // end of while (balancing)
    _length++;
    return true;
  }

  /// Test to see if an element is stored in the tree
  AvlNode<V> _getNode(V element) {
    if (element == null) return null;
    AvlNode<V> x = _root;
    while (x != null) {
      int compare = comparator(element, x.object);
      if (compare == 0) {
        // This only means our node matches; we need to search for the exact
        // element. We could have been glutons and used a hashmap to back.
        return x;
      } else if (compare < 0) {
        x = x.left;
      } else {
        x = x.right;
      }
    }
    return null;
  }

  /// This function will right rotate/pivot N with its left child, placing
  /// it on the right of its left child.
  ///
  ///          N                      Y
  ///         / \                    / \
  ///        Y   A                  Z   N
  ///       / \          ==>       / \ / \
  ///      Z   B                  D  CB   A
  ///     / \
  ///    D   C
  ///
  /// Assertion: must have a left element
  void _rotateRight(AvlNode<V> node) {
    AvlNode<V> y = node.left;
    if (y == null) throw new AssertionError();

    // turn Y's right subtree(B) into N's left subtree.
    node._left = y.right;
    if (node.left != null) {
      node.left._parent = node;
    }
    y._parent = node.parent;
    if (y._parent == null) {
      _root = y;
    } else {
      if (node.parent._left == node) {
        node.parent._left = y;
      } else {
        node.parent._right = y;
      }
    }
    y._right = node;
    node._parent = y;
  }

  /// This function will left rotate/pivot N with its right child, placing
  /// it on the left of its right child.
  ///
  ///      N                      Y
  ///     / \                    / \
  ///    A   Y                  N   Z
  ///       / \      ==>       / \ / \
  ///      B   Z              A  BC   D
  ///         / \
  ///        C   D
  ///
  /// Assertion: must have a right element
  void _rotateLeft(AvlNode<V> node) {
    AvlNode<V> y = node.right;
    if (y == null) throw new AssertionError();

    // turn Y's left subtree(B) into N's right subtree.
    node._right = y.left;
    if (node.right != null) {
      node.right._parent = node;
    }
    y._parent = node.parent;
    if (y._parent == null) {
      _root = y;
    } else {
      if (node.parent._left == node) {
        y.parent._left = y;
      } else {
        y.parent._right = y;
      }
    }
    y._left = node;
    node._parent = y;
  }

  /// This function will double rotate node with right/left operations.
  /// node is S.
  ///
  ///      S                      G
  ///     / \                    / \
  ///    A   C                  S   C
  ///       / \      ==>       / \ / \
  ///      G   B              A  DC   B
  ///     / \
  ///    D   C
  void _rotateRightLeft(AvlNode<V> node) {
    _rotateRight(node.right);
    _rotateLeft(node);
  }

  /// This function will double rotate node with left/right operations.
  /// node is S.
  ///
  ///        S                      G
  ///       / \                    / \
  ///      C   A                  C   S
  ///     / \          ==>       / \ / \
  ///    B   G                  B  CD   A
  ///       / \
  ///      C   D
  void _rotateLeftRight(AvlNode<V> node) {
    _rotateLeft(node.left);
    _rotateRight(node);
  }

  bool addAll(Iterable<V> items) {
    bool modified = false;
    for (V ele in items) {
      modified = add(ele) ? true : modified;
    }
    return modified;
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  AvlTreeSet<T> cast<T>() {
    throw new UnimplementedError("cast");
  }

  void clear() {
    _length = 0;
    _root = null;
    ++_modCount;
  }

  bool containsAll(Iterable<Object> items) {
    for (var ele in items) {
      if (!contains(ele)) return false;
    }
    return true;
  }

  bool remove(Object item) {
    if (item is! V) return false;

    AvlNode<V> x = _getNode(item as V);
    if (x != null) {
      _removeNode(x);
      return true;
    }
    return false;
  }

  void _removeNode(AvlNode<V> node) {
    AvlNode<V> y, w;

    ++_modCount;
    --_length;

    // note: if you read wikipedia, it states remove the node if its a leaf,
    // otherwise, replace it with its predecessor or successor. We're not.
    if (node._right == null || node.right._left == null) {
      // simple solutions
      if (node.right != null) {
        y = node.right;
        y._parent = node.parent;
        y._balanceFactor = node._balanceFactor - 1;
        y._left = node.left;
        if (y.left != null) {
          y.left._parent = y;
        }
      } else if (node.left != null) {
        y = node.left;
        y._parent = node.parent;
        y._balanceFactor = node._balanceFactor + 1;
      } else {
        y = null;
      }
      if (_root == node) {
        _root = y;
      } else if (node.parent._left == node) {
        node.parent._left = y;
        if (y == null) {
          // account for leaf deletions changing the balance
          node.parent._balanceFactor += 1;
          y = node.parent; // start searching from here;
        }
      } else {
        node.parent._right = y;
        if (y == null) {
          node.parent._balanceFactor -= 1;
          y = node.parent;
        }
      }
      w = y;
    } else {
      // This node is not a leaf; we should find the successor node, swap
      //it with this* and then update the balance factors.
      y = node.successor;
      y._left = node.left;
      if (y.left != null) {
        y.left._parent = y;
      }

      w = y.parent;
      w._left = y.right;
      if (w.left != null) {
        w.left._parent = w;
      }
      // known: we're removing from the left
      w._balanceFactor += 1;

      // known due to test for n->r->l above
      y._right = node.right;
      y.right._parent = y;
      y._balanceFactor = node._balanceFactor;

      y._parent = node.parent;
      if (_root == node) {
        _root = y;
      } else if (node.parent._left == node) {
        node.parent._left = y;
      } else {
        node.parent._right = y;
      }
    }

    // Safe to kill node now; its free to go.
    node._balanceFactor = 0;
    node._left = node._right = node._parent = null;
    node.object = null;

    // Recalculate max values all the way to the top.
    node = w;
    while (node != null) {
      node = node.parent;
    }

    // Re-balance to the top, ending early if OK
    node = w;
    while (node != null) {
      if (node._balanceFactor == -1 || node._balanceFactor == 1) {
        // The height of node hasn't changed; done!
        break;
      }
      if (node._balanceFactor == 2) {
        // Heavy on the right side; figure out which rotation to perform
        if (node.right._balanceFactor == -1) {
          _rotateRightLeft(node);
          node = node.parent; // old grand-child!
          if (node._balanceFactor == 1) {
            node.right._balanceFactor = 0;
            node.left._balanceFactor = -1;
          } else if (node._balanceFactor == 0) {
            node.right._balanceFactor = 0;
            node.left._balanceFactor = 0;
          } else {
            node.right._balanceFactor = 1;
            node.left._balanceFactor = 0;
          }
          node._balanceFactor = 0;
        } else {
          // single left-rotation
          _rotateLeft(node);
          if (node.parent._balanceFactor == 0) {
            node.parent._balanceFactor = -1;
            node._balanceFactor = 1;
            break;
          } else {
            node.parent._balanceFactor = 0;
            node._balanceFactor = 0;
            node = node.parent;
            continue;
          }
        }
      } else if (node._balanceFactor == -2) {
        // Heavy on the left
        if (node.left._balanceFactor == 1) {
          _rotateLeftRight(node);
          node = node.parent; // old grand-child!
          if (node._balanceFactor == -1) {
            node.right._balanceFactor = 1;
            node.left._balanceFactor = 0;
          } else if (node._balanceFactor == 0) {
            node.right._balanceFactor = 0;
            node.left._balanceFactor = 0;
          } else {
            node.right._balanceFactor = 0;
            node.left._balanceFactor = -1;
          }
          node._balanceFactor = 0;
        } else {
          _rotateRight(node);
          if (node.parent._balanceFactor == 0) {
            node.parent._balanceFactor = 1;
            node._balanceFactor = -1;
            break;
          } else {
            node.parent._balanceFactor = 0;
            node._balanceFactor = 0;
            node = node.parent;
            continue;
          }
        }
      }

      // continue up the tree for testing
      if (node.parent != null) {
        // The concept of balance here is reverse from addition; since
        // we are taking away weight from one side or the other (thus
        // the balance changes in favor of the other side)
        if (node.parent.left == node) {
          node.parent._balanceFactor += 1;
        } else {
          node.parent._balanceFactor -= 1;
        }
      }
      node = node.parent;
    }
  }

  /// See [Set.removeAll]
  void removeAll(Iterable items) {
    for (var ele in items) {
      remove(ele);
    }
  }

  /// See [Set.retainAll]
  void retainAll(Iterable<Object> elements) {
    List<V> chosen = <V>[];
    for (var target in elements) {
      if (target is V && contains(target)) {
        chosen.add(target);
      }
    }
    clear();
    addAll(chosen);
  }

  /// See [Set.retainWhere]
  void retainWhere(bool test(V element)) {
    List<V> chosen = [];
    for (var target in this) {
      if (test(target)) {
        chosen.add(target);
      }
    }
    clear();
    addAll(chosen);
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Set<T> retype<T>() {
    throw new UnimplementedError("retype");
  }

  /// See [Set.removeWhere]
  void removeWhere(bool test(V element)) {
    List<V> damned = [];
    for (var target in this) {
      if (test(target)) {
        damned.add(target);
      }
    }
    removeAll(damned);
  }

  /// See [IterableBase.first]
  V get first {
    if (_root == null) return null;
    AvlNode<V> min = _root.minimumNode;
    return min != null ? min.object : null;
  }

  /// See [IterableBase.last]
  V get last {
    if (_root == null) return null;
    AvlNode<V> max = _root.maximumNode;
    return max != null ? max.object : null;
  }

  /// See [Set.lookup]
  V lookup(Object element) {
    if (element is! V || _root == null) return null;
    AvlNode<V> x = _root;
    int compare = 0;
    while (x != null) {
      compare = comparator(element as V, x.object);
      if (compare == 0) {
        return x.object;
      } else if (compare < 0) {
        x = x.left;
      } else {
        x = x.right;
      }
    }
    return null;
  }

  V nearest(V object, {TreeSearch nearestOption: TreeSearch.NEAREST}) {
    AvlNode<V> found = _searchNearest(object, option: nearestOption);
    return (found != null) ? found.object : null;
  }

  /// Search the tree for the matching element, or the 'nearest' node.
  /// NOTE: [BinaryTree.comparator] needs to have finer granulatity than -1,0,1
  /// in order for this to return something that's meaningful.
  AvlNode<V> _searchNearest(V element,
      {TreeSearch option: TreeSearch.NEAREST}) {
    if (element == null || _root == null) {
      return null;
    }
    AvlNode<V> x = _root;
    AvlNode<V> previous;
    int compare = 0;
    while (x != null) {
      previous = x;
      compare = comparator(element, x.object);
      if (compare == 0) {
        return x;
      } else if (compare < 0) {
        x = x.left;
      } else {
        x = x.right;
      }
    }

    if (option == TreeSearch.GREATER_THAN) {
      return (compare < 0) ? previous : previous.successor;
    } else if (option == TreeSearch.LESS_THAN) {
      return (compare < 0) ? previous.predecessor : previous;
    }
    // Default: nearest absolute value
    // Fell off the tree looking for the exact match; now we need
    // to find the nearest element.
    x = (compare < 0) ? previous.predecessor : previous.successor;
    if (x == null) {
      return previous;
    }
    int otherCompare = comparator(element, x.object);
    if (compare < 0) {
      return compare.abs() < otherCompare ? previous : x;
    }
    return otherCompare.abs() < compare ? x : previous;
  }

  //
  // [IterableBase]<V> Methods
  //

  /// See [IterableBase.iterator]
  BidirectionalIterator<V> get iterator => new _AvlTreeIterator._(this);

  /// See [TreeSet.reverseIterator]
  BidirectionalIterator<V> get reverseIterator =>
      new _AvlTreeIterator._(this, reversed: true);

  /// See [TreeSet.fromIterator]
  BidirectionalIterator<V> fromIterator(V anchor,
          {bool reversed: false, bool inclusive: true}) =>
      new _AvlTreeIterator<V>._(this,
          anchorObject: anchor, reversed: reversed, inclusive: inclusive);

  /// See [IterableBase.contains]
  bool contains(Object object) {
    AvlNode<V> x = _getNode(object as V);
    return x != null;
  }

  //
  // [Set] methods
  //

  /// See [Set.intersection]
  Set<V> intersection(Set<Object> other) {
    TreeSet<V> set = new TreeSet(comparator: comparator);

    // Optimized for sorted sets
    if (other is TreeSet<V>) {
      var i1 = iterator;
      var i2 = other.iterator;
      var hasMore1 = i1.moveNext();
      var hasMore2 = i2.moveNext();
      while (hasMore1 && hasMore2) {
        var c = comparator(i1.current, i2.current);
        if (c == 0) {
          set.add(i1.current);
          hasMore1 = i1.moveNext();
          hasMore2 = i2.moveNext();
        } else if (c < 0) {
          hasMore1 = i1.moveNext();
        } else {
          hasMore2 = i2.moveNext();
        }
      }
      return set;
    }

    // Non-optimized version.
    for (var target in this) {
      if (other.contains(target)) {
        set.add(target);
      }
    }
    return set;
  }

  /// See [Set.union]
  Set<V> union(Set<V> other) {
    TreeSet<V> set = new TreeSet(comparator: comparator);

    if (other is TreeSet) {
      var i1 = iterator;
      var i2 = other.iterator;
      var hasMore1 = i1.moveNext();
      var hasMore2 = i2.moveNext();
      while (hasMore1 && hasMore2) {
        var c = comparator(i1.current, i2.current);
        if (c == 0) {
          set.add(i1.current);
          hasMore1 = i1.moveNext();
          hasMore2 = i2.moveNext();
        } else if (c < 0) {
          set.add(i1.current);
          hasMore1 = i1.moveNext();
        } else {
          set.add(i2.current);
          hasMore2 = i2.moveNext();
        }
      }
      if (hasMore1 || hasMore2) {
        i1 = hasMore1 ? i1 : i2;
        do {
          set.add(i1.current);
        } while (i1.moveNext());
      }
      return set;
    }

    // Non-optimized version.
    return set..addAll(this)..addAll(other);
  }

  /// See [Set.difference]
  Set<V> difference(Set<Object> other) {
    TreeSet<V> set = new TreeSet(comparator: comparator);

    if (other is TreeSet) {
      var i1 = iterator;
      var i2 = other.iterator;
      var hasMore1 = i1.moveNext();
      var hasMore2 = i2.moveNext();
      while (hasMore1 && hasMore2) {
        var c = comparator(i1.current, i2.current);
        if (c == 0) {
          hasMore1 = i1.moveNext();
          hasMore2 = i2.moveNext();
        } else if (c < 0) {
          set.add(i1.current);
          hasMore1 = i1.moveNext();
        } else {
          hasMore2 = i2.moveNext();
        }
      }
      if (hasMore1) {
        do {
          set.add(i1.current);
        } while (i1.moveNext());
      }
      return set;
    }

    // Non-optimized version.
    for (var target in this) {
      if (!other.contains(target)) {
        set.add(target);
      }
    }
    return set;
  }

  @visibleForTesting
  AvlNode<V> getNode(V object) => _getNode(object);
}

typedef bool _IteratorMove();

/// This iterator either starts at the beginning or end (see [TreeSet.iterator]
/// and [TreeSet.reverseIterator]) or from an anchor point in the set (see
/// [TreeSet.fromIterator]). When using fromIterator, the inital anchor point
/// is included in the first movement (either [moveNext] or [movePrevious]) but
/// can optionally be excluded in the constructor.
class _AvlTreeIterator<V> implements BidirectionalIterator<V> {
  static const LEFT = -1;
  static const WALK = 0;
  static const RIGHT = 1;

  final bool reversed;
  final AvlTreeSet<V> tree;
  final int _modCountGuard;
  final V anchorObject;
  final bool inclusive;

  _IteratorMove _moveNext;
  _IteratorMove _movePrevious;

  int state;
  _TreeNode<V> _current;

  _AvlTreeIterator._(AvlTreeSet<V> tree,
      {reversed: false, this.inclusive: true, this.anchorObject: null})
      : this.tree = tree,
        this._modCountGuard = tree._modCount,
        this.reversed = reversed {
    if (anchorObject == null || tree.length == 0) {
      // If the anchor is far left or right, we're just a normal iterator.
      state = reversed ? RIGHT : LEFT;
      _moveNext = reversed ? _movePreviousNormal : _moveNextNormal;
      _movePrevious = reversed ? _moveNextNormal : _movePreviousNormal;
      return;
    }

    state = WALK;
    // Else we've got an anchor we have to worry about initalizing from.
    // This isn't known till the caller actually performs a previous/next.
    _moveNext = () {
      _current = tree._searchNearest(anchorObject,
          option: reversed ? TreeSearch.LESS_THAN : TreeSearch.GREATER_THAN);
      _moveNext = reversed ? _movePreviousNormal : _moveNextNormal;
      _movePrevious = reversed ? _moveNextNormal : _movePreviousNormal;
      if (_current == null) {
        state = reversed ? LEFT : RIGHT;
      } else if (tree.comparator(_current.object, anchorObject) == 0 &&
          !inclusive) {
        _moveNext();
      }
      return state == WALK;
    };

    _movePrevious = () {
      _current = tree._searchNearest(anchorObject,
          option: reversed ? TreeSearch.GREATER_THAN : TreeSearch.LESS_THAN);
      _moveNext = reversed ? _movePreviousNormal : _moveNextNormal;
      _movePrevious = reversed ? _moveNextNormal : _movePreviousNormal;
      if (_current == null) {
        state = reversed ? RIGHT : LEFT;
      } else if (tree.comparator(_current.object, anchorObject) == 0 &&
          !inclusive) {
        _movePrevious();
      }
      return state == WALK;
    };
  }

  V get current => (state != WALK || _current == null) ? null : _current.object;

  bool moveNext() => _moveNext();
  bool movePrevious() => _movePrevious();

  bool _moveNextNormal() {
    if (_modCountGuard != tree._modCount) {
      throw new ConcurrentModificationError(tree);
    }
    if (state == RIGHT || tree.length == 0) return false;
    switch (state) {
      case LEFT:
        _current = tree._root.minimumNode;
        state = WALK;
        return true;
      case WALK:
      default:
        _current = _current.successor;
        if (_current == null) {
          state = RIGHT;
        }
        return state == WALK;
    }
  }

  bool _movePreviousNormal() {
    if (_modCountGuard != tree._modCount) {
      throw new ConcurrentModificationError(tree);
    }
    if (state == LEFT || tree.length == 0) return false;
    switch (state) {
      case RIGHT:
        _current = tree._root.maximumNode;
        state = WALK;
        return true;
      case WALK:
      default:
        _current = _current.predecessor;
        if (_current == null) {
          state = LEFT;
        }
        return state == WALK;
    }
  }
}

/// Private class used to track element insertions in the [TreeSet].
class AvlNode<V> extends _TreeNode<V> {
  AvlNode<V> _left;
  AvlNode<V> _right;
  // TODO(codefu): Remove need for [parent]; this is just an implementation note
  AvlNode<V> _parent;
  int _balanceFactor = 0;

  AvlNode<V> get left => _left;
  AvlNode<V> get right => _right;
  AvlNode<V> get parent => _parent;
  int get balance => _balanceFactor;

  AvlNode({V object}) : super(object: object);

  String toString() =>
      "(b:$balance o: $object l:${left != null} r:${right != null})";
}
