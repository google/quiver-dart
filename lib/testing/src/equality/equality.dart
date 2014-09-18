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
 * To use, invoke expectEquals with a list of equality groups where each group
 * contains objects that are supposed to be equal to each other, and objects of
 * different groups are expected to be unequal. For example:
 *
 * expectEquals({
 *      'hello': ["hello", "h" + "ello"],
 *      'world': ["world", "wor" + "ld"],
 *      'three': [2, 1 + 1]
 *     });
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
 *      "`[group i, item j]`" refers to the jth item in the ith equality group,
 *       where both equality groups and the items within equality groups are
 *       numbered starting from 1.  When either a constructor argument or an
 *       equal object is provided, that becomes group 1.
 *
 */
const REPETITIONS = 3;

void expectEquals(Map<String, List<Object>> equalityGroups) {
  assert(equalityGroups != null);
  var equalityGroupsCopy = {};
  equalityGroups.keys.forEach((String groupName) {
    assert(groupName != null);
    var group = equalityGroups[groupName];
    assert(group != null);
    equalityGroupsCopy[groupName] = new List.from(group);
  });
  // Run the test multiple times to ensure deterministic equals
  for (var run in range(REPETITIONS)) {
    _checkBasicIdentity(equalityGroupsCopy);
    _checkGroupBasedEquality(equalityGroupsCopy);
  }
}

void _checkBasicIdentity(Map<String, List<Object>> equalityGroups) {
  var flattened = equalityGroups.values.expand((group) => group);
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

void _checkGroupBasedEquality(Map<String, List<Object>> equalityGroups) {
//  for (var groupNumber = 0; groupNumber < equalityGroups.length;
//      groupNumber++) {
  equalityGroups.keys.forEach((String groupName) {
    var groupLength = equalityGroups[groupName].length;
    for (var itemNumber = 0; itemNumber < groupLength; itemNumber++) {
      _checkEqualAgainstSameGroup(equalityGroups, groupLength, itemNumber,
          groupName);
      _checkUnequalsAgainstOtherGroups(equalityGroups, groupName, itemNumber);
    }
  });
}

void _checkUnequalsAgainstOtherGroups(Map<String, List<Object>> equalityGroups,
  String groupName, int itemNumber) {

//  for (var unrelatedGroupNumber = 0;
//      unrelatedGroupNumber < equalityGroups.length; unrelatedGroupNumber++) {
    equalityGroups.keys.forEach((String unrelatedGroupName) {
      if (groupName != unrelatedGroupName) {
        var unrelatedGroup = equalityGroups[unrelatedGroupName];
        for (var unrelatedItemNumber = 0;
            unrelatedItemNumber < unrelatedGroup.length;
            unrelatedItemNumber++) {
          _expectUnrelated(
              equalityGroups,
              groupName,
              itemNumber,
              unrelatedGroupName,
              unrelatedItemNumber);
        }
      }
  });
}

void _checkEqualAgainstSameGroup(Map<String, List<Object>> equalityGroups,
  int groupLength, int itemNumber, String groupName) {
  for (var relatedItemNumber = 0; relatedItemNumber < groupLength;
      relatedItemNumber++) {
    if (itemNumber != relatedItemNumber) {
      _expectRelated(equalityGroups, groupName, itemNumber,
          relatedItemNumber);
    }
  }
}

void _expectRelated(Map<String, List<Object>> equalityGroups, String groupName,
  int itemNumber, int relatedItemNumber) {
  var itemInfo = _createItem(equalityGroups, groupName, itemNumber);
  var relatedInfo = _createItem(equalityGroups, groupName,
      relatedItemNumber);

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

void _expectUnrelated(Map<String, List<Object>> equalityGroups, String groupName,
  int itemNumber, String unrelatedGroupName, int unrelatedItemNumber) {
  var itemInfo = _createItem(equalityGroups, groupName, itemNumber);
  var unrelatedInfo = _createItem(equalityGroups, unrelatedGroupName,
      unrelatedItemNumber);

  if (itemInfo.value == unrelatedInfo.value) {
    fail("$itemInfo must not be Object#equals to $unrelatedInfo)");
  }
}

_Item _createItem(Map<String, List<Object>> equalityGroups,
  String groupName, int itemNumber) =>
  new _Item(
      equalityGroups[groupName][itemNumber],
      groupName,
      itemNumber);


class _NotAnInstance {
  static const EQUAL_TO_NOTHING = const _NotAnInstance._();
  const _NotAnInstance._();
}

class _Item {
  final Object value;
  final String groupName;
  final int itemNumber;

  _Item(this.value, this.groupName, this.itemNumber);

  @override
  String toString() => "$value [group '$groupName', item ${(itemNumber + 1)}]";
}