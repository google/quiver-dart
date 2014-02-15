// Copyright 2013 Google Inc. All Rights Reserved.
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
 * A [Set] of items stored in a binary tree according to [comparator].
 * Supports bidirectional iteration.
 */
abstract class TreeSet<V> extends IterableBase<V> implements Set<V> {

  final Comparator<V> comparator;

  int get length;

  // Modification count to the tree, monotonically increasing
  int _modCount = 0;

  TreeNode<V> get _root;

  /**
   * Create a new [TreeSet] with an ordering defined by [comparator].
   */
  factory TreeSet({Comparator<V> comparator: Comparable.compare}) =>
    new AvlTreeSet(comparator: comparator);

  TreeSet._(this.comparator);

  /**
   * Returns an Iterator that iterates over this tree, in reverse.
   */
  Iterator<V> get reversed;


  /**
   * Search the tree for the matching [object] or the [nearestOption]
   * if missing.  See [TreeSearch].
   */
  V nearest(V object, {TreeSearch nearestOption: TreeSearch.NEAREST});
}


/**
 * Controls the results for [TreeSet.searchNearest]()
 */
class TreeSearch {

  /**
   * If result not found, always chose the smaler element
   */
  static const LESS_THAN = const TreeSearch(1);

  /**
   * If result not found, chose the nearest based on comparison
   */
  static const NEAREST = const TreeSearch(2);

  /**
   * If result not found, always chose the greater element
   */
  static const GREATER_THAN = const TreeSearch(3);

  final int _val;
  const TreeSearch(this._val);
}


/**
 * A node in the [TreeSet].
 */
abstract class TreeNode<V> {

  TreeNode<V> left;
  TreeNode<V> right;

  //TODO(codefu): Remove need for [parent]; this is just an implementation note
  TreeNode<V> parent;
  V object;

  TreeNode({this.left, this.right, this.parent, this.object});

  /**
   *  Return the minimum node for the subtree
   */
  TreeNode<V> get minimumNode {
    var node = this;
    while (node.left != null) {
      node = node.left;
    }
    return node;
  }

  /**
   *  Return the maximum node for the subtree
   */
  TreeNode<V> get maximumNode {
    var node = this;
    while (node.right != null) {
      node = node.right;
    }
    return node;
  }

  /**
   *  Return the next greatest element (or null)
   */
  TreeNode<V> get successor {
    var node = this;
    if (node.right != null) {
      return node.right.minimumNode;
    }
    while (node.parent != null && node == node.parent.right) {
      node = node.parent;
    }
    return node.parent;
  }

  /**
   *  Return the next smaller element (or null)
   */
  TreeNode<V> get predecessor {
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


/**
 * AVL implementation of a self-balancing binary tree. Optimized for lookup
 * operations.
 *
 * Notes: Adapted from "Introduction to Algorithms", second edition,
 *        by Thomas H. Cormen, Charles E. Leiserson,
 *           Ronald L. Rivest, Clifford Stein.
 *        chapter 13.2
 */
class AvlTreeSet<V> extends TreeSet<V> {

  int length = 0;

  AvlNode<V> _root;

  AvlTreeSet({Comparator<V> comparator: Comparable.compare})
      : super._(comparator);

  /**
   * Add the element to the tree.
   */
  bool add(V element) {
    if (_root == null) {
      AvlNode<V> node = new AvlNode<V>();
      node.object = element;
      _root = node;
      ++length;
      ++_modCount;
      return true;
    }

    AvlNode<V> x = _root;
    while (true) {
      int compare = comparator(element, x.object);
      if (compare == 0) {
        return false;
      } else if (compare < 0) {
        if (x.left == null) {
          AvlNode<V> node = new AvlNode<V>();
          node.object = element;
          node.parent = x;
          x.left = node;
          x.balanceFactor -= 1;
          break;
        }
        x = x.left;
      } else {
        if (x.right == null) {
          AvlNode<V> node = new AvlNode<V>();
          node.object = element;
          node.parent = x;
          x.right = node;
          x.balanceFactor += 1;
          break;
        }
        x = x.right;
      }
    }

    ++_modCount;

    // AVL balancing act (for height balanced trees)
    // Now that we've inserted, we've unbalanced some trees, we need
    //  to follow the tree back up to the root double checking that the tree
    //  is still balanced and _maybe_ perform a single or double rotation.
    //  Note: Left additions == -1, Right additions == +1
    //  Balanced Node = { -1, 0, 1 }, out of balance = { -2, 2 }
    //  Single rotation when Parent & Child share signed balance,
    //  Double rotation when sign differs!
    AvlNode<V> node = x;
    while (node.balanceFactor != 0 && node.parent != null) {
      // Find out which side of the parent we're on
      if (node.parent.left == node) {
        // Lefties are -1 since we hate lefties
        node.parent.balanceFactor -= 1;
      } else {
        node.parent.balanceFactor += 1;
      }

      node = node.parent;
      if (node.balanceFactor == 2) {
        // Heavy on the right side - Test for which rotation to perform
        if (node.right.balanceFactor == 1) {
          // Single (left) rotation; this will balance everything to zero
          _rotateLeft(node);
          node.balanceFactor = node.parent.balanceFactor = 0;
          node = node.parent;
        } else {
          // Double (Right/Left) rotation
          // node will now be old node.right.left
          _rotateRightLeft(node);
          node = node.parent; // Update to new parent (old grandchild)
          if (node.balanceFactor == 1) {
            node.right.balanceFactor = 0;
            node.left.balanceFactor = -1;
          } else if (node.balanceFactor == 0) {
            node.right.balanceFactor = 0;
            node.left.balanceFactor = 0;
          } else {
            node.right.balanceFactor = 1;
            node.left.balanceFactor = 0;
          }
          node.balanceFactor = 0;
        }
        break; // out of loop, we're balanced
      } else if (node.balanceFactor == -2) {
        // Heavy on the left side - Test for which rotation to perform
        if (node.left.balanceFactor == -1) {
          _rotateRight(node);
          node.balanceFactor = node.parent.balanceFactor = 0;
          node = node.parent;
        } else {
          // Double (Left/Right) rotation
          // node will now be old node.left.right
          _rotateLeftRight(node);
          node = node.parent;
          if (node.balanceFactor == -1) {
            node.right.balanceFactor = 1;
            node.left.balanceFactor = 0;
          } else if (node.balanceFactor == 0) {
            node.right.balanceFactor = 0;
            node.left.balanceFactor = 0;
          } else {
            node.right.balanceFactor = 0;
            node.left.balanceFactor = -1;
          }
          node.balanceFactor = 0;
        }
        break; // out of loop, we're balanced
      }
    } // end of while (balancing)
    length++;
    return true;
  }

  /**
   * Test to see if an element is stored in the tree
   */
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

  /**
   * This function will right rotate/pivot N with its left child, placing
   * it on the right of its left child.
   *
   *      N                      Y
   *     / \                    / \
   *    Y   A                  Z   N
   *   / \          ==>       / \ / \
   *  Z   B                  D  CB   A
   * / \
   *D   C
   *
   * Assertion: must have a left element
   */
  void _rotateRight(AvlNode<V> node) {
    AvlNode<V> y = node.left;
    if (y == null) throw new AssertionError();

    // turn Y's right subtree(B) into N's left subtree.
    node.left = y.right;
    if (node.left != null) {
      node.left.parent = node;
    }
    y.parent = node.parent;
    if (y.parent == null) {
      _root = y;
    } else {
      if (node.parent.left == node) {
        node.parent.left = y;
      } else {
        node.parent.right = y;
      }
    }
    y.right = node;
    node.parent = y;
  }

  /**
   * This function will left rotate/pivot N with its right child, placing
   * it on the left of its right child.
   *
   *      N                      Y
   *     / \                    / \
   *    A   Y                  N   Z
   *       / \      ==>       / \ / \
   *      B   Z              A  BC   D
   *         / \
   *        C   D
   *
   * Assertion: must have a right element
   */
  void _rotateLeft(AvlNode<V> node) {
    AvlNode<V> y = node.right;
    if (y == null) throw new AssertionError();

    // turn Y's left subtree(B) into N's right subtree.
    node.right = y.left;
    if (node.right != null) {
      node.right.parent = node;
    }
    y.parent = node.parent;
    if (y.parent == null) {
      _root = y;
    } else {
      if (node.parent.left == node) {
        y.parent.left = y;
      } else {
        y.parent.right = y;
      }
    }
    y.left = node;
    node.parent = y;
  }

  /**
   *  This function will double rotate node with right/left operations.
   *  node is S.
   *
   *    S                      G
   *   / \                    / \
   *  A   C                  S   C
   *     / \      ==>       / \ / \
   *    G   B              A  DC   B
   *   / \
   *  D   C
   */
  void _rotateRightLeft(AvlNode<V> node) {
    _rotateRight(node.right);
    _rotateLeft(node);
  }

  /**
   * This function will double rotate node with left/right operations.
   * node is S.
   *
   *    S                      G
   *   / \                    / \
   *  C   A                  C   S
   * / \          ==>       / \ / \
   *B   G                  B  CD   A
   *   / \
   *  C   D
   */
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

  void clear() {
    length = 0;
    _root = null;
  }

  bool containsAll(Iterable<Object> items) {
    for (var ele in items) {
      if (!contains(ele)) return false;;
    }
    return true;
  }

  bool remove(Object item) {
    AvlNode<V> x = _getNode(item);
    if (x != null) {
      _removeNode(x);
      return true;
    }
    return false;
  }

  void _removeNode(AvlNode<V> node) {
    AvlNode<V> y, w;

    ++_modCount;
    --length;

    // note: if you read wikipedia, it states remove the node if its a leaf,
    // otherwise, replace it with its predecessor or successor. We're not.
    if (node.right == null || node.right.left == null) {
      // simple solutions
      if (node.right != null) {
        y = node.right;
        y.parent = node.parent;
        y.balanceFactor = node.balanceFactor - 1;
        y.left = node.left;
        if (y.left != null) {
          y.left.parent = y;
        }
      } else if (node.left != null) {
        y = node.left;
        y.parent = node.parent;
        y.balanceFactor = node.balanceFactor + 1;
      } else {
        y = null;
      }
      if (_root == node) {
        _root = y;
      } else if (node.parent.left == node) {
        node.parent.left = y;
        if (y == null) {
          // account for leaf deletions changing the balance
          node.parent.balanceFactor += 1;
          y = node.parent; // start searching from here;
        }
      } else {
        node.parent.right = y;
        if (y == null) {
          node.parent.balanceFactor -= 1;
          y = node.parent;
        }
      }
      w = y;
    } else {
      // This node is not a leaf; we should find the successor node, swap
      //it with this* and then update the balance factors.
      y = node.successor;
      y.left = node.left;
      if (y.left != null) {
        y.left.parent = y;
      }

      w = y.parent;
      w.left = y.right;
      if (w.left != null) {
        w.left.parent = w;
      }
      // known: we're removing from the left
      w.balanceFactor += 1;

      // known due to test for n->r->l above
      y.right = node.right;
      y.right.parent = y;
      y.balanceFactor = node.balanceFactor;

      y.parent = node.parent;
      if (_root == node) {
        _root = y;
      } else if (node.parent.left == node) {
        node.parent.left = y;
      } else {
        node.parent.right = y;
      }
    }

    // Safe to kill node now; its free to go.
    node.balanceFactor = 0;
    node.left = node.right = node.parent = null;
    node.object = null;

    // Recalculate max values all the way to the top.
    node = w;
    while (node != null) {
      node = node.parent;
    }

    // Re-balance to the top, ending early if OK
    node = w;
    while (node != null) {
      if (node.balanceFactor == -1 || node.balanceFactor == 1) {
        // The height of node hasn't changed; done!
        break;
      }
      if (node.balanceFactor == 2) {
        // Heavy on the right side; figure out which rotation to perform
        if (node.right.balanceFactor == -1) {
          _rotateRightLeft(node);
          node = node.parent; // old grand-child!
          if (node.balanceFactor == 1) {
            node.right.balanceFactor = 0;
            node.left.balanceFactor = -1;
          } else if (node.balanceFactor == 0) {
            node.right.balanceFactor = 0;
            node.left.balanceFactor = 0;
          } else {
            node.right.balanceFactor = 1;
            node.left.balanceFactor = 0;
          }
          node.balanceFactor = 0;
        } else {
          // single left-rotation
          _rotateLeft(node);
          if (node.parent.balanceFactor == 0) {
            node.parent.balanceFactor = -1;
            node.balanceFactor = 1;
            break;
          } else {
            node.parent.balanceFactor = 0;
            node.balanceFactor = 0;
            node = node.parent;
            continue;
          }
        }
      } else if (node.balanceFactor == -2) {
        // Heavy on the left
        if (node.left.balanceFactor == 1) {
          _rotateLeftRight(node);
          node = node.parent; // old grand-child!
          if (node.balanceFactor == -1) {
            node.right.balanceFactor = 1;
            node.left.balanceFactor = 0;
          } else if (node.balanceFactor == 0) {
            node.right.balanceFactor = 0;
            node.left.balanceFactor = 0;
          } else {
            node.right.balanceFactor = 0;
            node.left.balanceFactor = -1;
          }
          node.balanceFactor = 0;
        } else {
          _rotateRight(node);
          if (node.parent.balanceFactor == 0) {
            node.parent.balanceFactor = 1;
            node.balanceFactor = -1;
            break;
          } else {
            node.parent.balanceFactor = 0;
            node.balanceFactor = 0;
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
          node.parent.balanceFactor += 1;
        } else {
          node.parent.balanceFactor -= 1;
        }
      }
      node = node.parent;
    }
  }

  /**
   * See [Set.removeAll]
   */
  void removeAll(Iterable items) {
    for (var ele in items) {
      remove(ele);
    }
  }

  /**
   * See [Set.retainAll]
   */
  void retainAll(Iterable<Object> elements) {
    List<V> chosen = [];
    for (var target in elements) {
      if (contains(target)) {
        chosen.add(target);
      }
    }
    clear();
    addAll(chosen);
  }

  /**
   * See [Set.retainWhere]
   */
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

  /**
   * See [Set.removeWhere]
   */
  void removeWhere(bool test(V element)) {
    List<V> damned = [];
    for (var target in this) {
      if (test(target)) {
        damned.add(target);
      }
    }
    removeAll(damned);
  }

  /**
   * See [IterableBase.first]
   */
  V get first {
    if (_root == null) return null;
    AvlNode<V> min = _root.minimumNode;
    return min != null ? min.object : null;
  }

  /**
   * See [IterableBase.last]
   */
  V get last {
    if (_root == null) return null;
    AvlNode<V> max = _root.maximumNode;
    return max != null ? max.object : null;
  }

  /**
   * See [Set.lookup]
   */
  V lookup(Object element) {
    if (element == null || _root == null)
      return null;
    AvlNode<V> x = _root;
    int compare = 0;
    while (x != null) {
      compare = comparator(element, x.object);
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
    AvlNode<V> found = _searchNearest(object, nearestOption);
    return (found != null) ? found.object : null;
  }

  /**
   * Search the tree for the matching element, or the 'nearest' node.
   * NOTE: [BinaryTree.comparator] needs to have finer granulatity than -1,0,1
   * in order for this to return something that's meaningful.
   */
  AvlNode<V> _searchNearest(V element, TreeSearch option) {
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

  /**
   * See [IterableBase.iterator]
   */
  Iterator<V> get iterator => new TreeIterator._(this);

  /**
   * See [IterableBase.revsered]
   */
  Iterator<V> get reversed => new TreeIterator._(this, reversed: true);

  /**
   * See [IterableBase.contains]
   */
  bool contains(Object object) {
    AvlNode<V> x = _getNode(object as V);
    return x != null;
  }


  //
  // [Set] methods
  //

  /**
   * See [Set.intersection]
   */
  Set<V> intersection(Set<Object> other) {
    /// Read [Set.intersection] carefully.
    TreeSet<V> set = new TreeSet(comparator: comparator);
    for (var target in this) {
      if (other.contains(target)) {
        set.add(target);
      }
    }
    return set;
  }

  /**
   * See [Set.union]
   */
  Set<V> union(Set<V> other) =>
      new TreeSet(comparator: comparator)
          ..addAll(this)
          ..addAll(other);

  /**
   * See [Set.difference]
   */
  Set<V> difference(Set<V> other) {
    /// Read [Set.difference] carefully.
    TreeSet<V> set = new TreeSet(comparator: comparator);
    for (var target in this) {
      if (!other.contains(target)) {
        set.add(target);
      }
    }
    return set;
  }

  /**
   * Visible for testing only.
   */
  AvlNode<V> getNode(V object) => _getNode(object);
}


class TreeIterator<V> implements BidirectionalIterator<V> {

  int _state;
  AvlNode<V> _current;

  final int _modCountGuard;
  final TreeSet<V> _tree;
  final bool reversed;

  TreeIterator._(TreeSet<V> tree, {this.reversed: false}) :
    _modCountGuard = tree._modCount,
    _tree = tree {
    _state = reversed ? 1 : -1;
  }

  V get current => (_state != 0 || _current == null) ? null : _current.object;

  bool moveNext() => reversed ? _movePrevious() : _moveNext();
  bool movePrevious() => reversed ? _moveNext() : _movePrevious();

  bool _moveNext() {
    if (_modCountGuard != _tree._modCount) {
      throw new ConcurrentModificationError(_tree);
    }
    if (_state == 1 || _tree.length == 0) return false;
    if (_state == -1) {
      _current = _tree._root.minimumNode;
      _state = 0;
      return true;
    }
    _current = _current.successor;
    if (_current == null) {
      _state = 1;
      return false;
    }
    return true;
  }

  bool _movePrevious() {
    if (_modCountGuard != _tree._modCount) {
      throw new ConcurrentModificationError(_tree);
    }
    if (_state == -1 || _tree.length == 0) return false;
    if (_state == 1) {
      _current = _tree._root.maximumNode;
      _state = 0;
      return true;
    }
    _current = _current.predecessor;
    if (_current == null) {
      _state = -1;
      return false;
    }
    return true;
  }
}


/**
 * Private class used to track element insertions in the [TreeSet].
 */
class AvlNode<V> extends TreeNode<V> {

  AvlNode({AvlNode left: null, AvlNode right: null,
      AvlNode parent: null, V object, this.balanceFactor: 0}) :
      super(left: left, right: right, parent: parent, object: object);

  int balanceFactor;

  String toString() =>
    "(b:$balanceFactor o: $object l:${left != null} r:${right != null})";
}
