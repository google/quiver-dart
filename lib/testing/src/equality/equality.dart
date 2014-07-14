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

part of quiver.testing.equality;


/**
 * Tester for == and hashCode methods of a class.
 *
 * To use, create a new EqualsTester and add equality groups where each group
 * contains objects that are supposed to be equal to each other, and objects of
 * different groups are expected to be unequal. For example:
 *
 * new EqualsTester()
 *     .addEqualityGroup(["hello", "h" + "ello"])
 *     .addEqualityGroup(["world", "wor" + "ld"])
 *     .addEqualityGroup([2, 1 + 1])
 *     .expectEquals();
 *
 * This tests:
 *
 * * comparing each object against itself returns true
 * * comparing each object against an instance of an incompatible class
 *     returns false
 * * comparing each pair of objects within the same equality group returns
 *     true
 * * comparing each pair of objects from different equality groups returns
 *     false
 * * the hash codes of any two equal objects are equal
 *
 *
 * When a test fails, the error message labels the objects involved in
 * the failed comparison as follows:
 *
 *      "`[group i, item j]`" refers to the
 *       jth item in the ith equality group,
 *       where both equality groups and the items within equality groups are
 *       numbered starting from 1.  When either a constructor argument or an
 *       equal object is provided, that becomes group 1.
 *
 */
class EqualsTester {
  static final int REPETITIONS = 3;

  final List<List<Object>> _equalityGroups = [];

  void addEqualityGroup(List<Object> equalityGroup) {
    assert(equalityGroup != null);
    _equalityGroups.add(new UnmodifiableListView(new List.from(equalityGroup)));
  }

  void expectEquals() {
    var delegate = new _RelationshipTester<Object>();
    for (var group in _equalityGroups) {
      delegate.addRelatedGroup(group);
    }
    for (var run in range(REPETITIONS)) {
      _testItems();
      delegate.test();
    }
  }

  void _testItems() {
    var flattened = _equalityGroups.fold([], (prev, group) =>
        prev..addAll(group));
    for (var item in flattened) {
      expect(_NotAnInstance.EQUAL_TO_NOTHING, isNot(equals(item)), reason:
        "$item must not be Object#equals to an arbitrary object of another "
        "class");
      expect(item, equals(item), reason:
        "$item must be Object#equals to itself");
      expect(item.hashCode, equals(item.hashCode), reason:
        "the Object#hashCode of $item must be consistent");
    }
  }
}

class _NotAnInstance {
  static const EQUAL_TO_NOTHING = const _NotAnInstance._();
  const _NotAnInstance._();
}

class _RelationshipTester<T> {
  final List<UnmodifiableListView<T>> _groups = [];

  void addRelatedGroup(Iterable<T> group) {
    _groups.add(new UnmodifiableListView(new List.from(group)));
  }

  void test() {
    for (var groupNumber = 0; groupNumber < _groups.length; groupNumber++) {
      var group = _groups[groupNumber];
      for (var itemNumber = 0; itemNumber < group.length; itemNumber++) {
        // check related items in same group
        for (var relatedItemNumber = 0; relatedItemNumber < group.length;
            relatedItemNumber++) {
          if (itemNumber != relatedItemNumber) {
            _expectRelated(groupNumber, itemNumber, relatedItemNumber);
          }
        }
        // check unrelated items in all other groups
        for (var unrelatedGroupNumber = 0;
            unrelatedGroupNumber < _groups.length; unrelatedGroupNumber++) {
          if (groupNumber != unrelatedGroupNumber) {
            var unrelatedGroup = _groups[unrelatedGroupNumber];
            for (var unrelatedItemNumber = 0;
                unrelatedItemNumber < unrelatedGroup.length;
                unrelatedItemNumber++) {
              _expectUnrelated(
                  groupNumber,
                  itemNumber,
                  unrelatedGroupNumber,
                  unrelatedItemNumber);
            }
          }
        }
      }
    }
  }

  void _expectRelated(int groupNumber, int itemNumber, int relatedItemNumber) {
    var itemInfo = _createItem(groupNumber, itemNumber);
    var relatedInfo = _createItem(groupNumber, relatedItemNumber);

    var item = itemInfo.value;
    var related = relatedInfo.value;
    if (item != related) {
      fail("$itemInfo must be Object#equals to $relatedInfo");
    }

    var itemHash = item.hashCode;
    var relatedHash = related.hashCode;
    if (itemHash != relatedHash) {
      fail("the Object#hashCode ($itemHash) of $itemInfo must be equal to the "
          "Object#hashCode ($relatedHash) of $relatedInfo}");
    }
  }

  void _expectUnrelated(int groupNumber, int itemNumber,
                        int unrelatedGroupNumber, int unrelatedItemNumber) {
    var itemInfo = _createItem(groupNumber, itemNumber);
    var unrelatedInfo = _createItem(unrelatedGroupNumber, unrelatedItemNumber);

    if (itemInfo.value == unrelatedInfo.value) {
      fail("$itemInfo must not be Object#equals to $unrelatedInfo)");
    }
  }

  _Item<T> _createItem(int groupNumber, int itemNumber) =>
    new _Item<T>(_groups[groupNumber][itemNumber], groupNumber, itemNumber);
}

class _Item<T> {
  final T value;
  final int groupNumber;
  final int itemNumber;

  _Item(this.value, this.groupNumber, this.itemNumber);

  @override
  String toString() =>
      "$value [group ${(groupNumber + 1)}, item ${(itemNumber + 1)}]";
}