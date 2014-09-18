// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library quiver.testing.util.equalstester;

import 'package:quiver/testing/equality.dart';
import 'package:unittest/unittest.dart';

main() {
  group('EqualsTester', () {
      _ValidTestObject reference;
      _ValidTestObject equalObject1;
      _ValidTestObject equalObject2;
      _ValidTestObject notEqualObject1;

      setUp(() {
        reference = new _ValidTestObject(1, 2);
        equalObject1 = new _ValidTestObject(1, 2);
        equalObject2 = new _ValidTestObject(1, 2);
        notEqualObject1 = new _ValidTestObject(0, 2);
      });

      test('Test null reference yields error', () {
        expect(() => expectEquals(null), throws);
      });

      test('Test equalObjects after adding multiple instances at once with a '
          'null', () {
        expect(() {
          expectEquals([[reference, equalObject1, null]]);
        }, throws);
      });

      test('Test adding null equal object yields error', () {
        expect(() {
          expectEquals([[reference, null]]);
        }, throws);
      });

      test('Test adding objects only by addEqualityGroup, with no reference '
       'object specified in the constructor.', () {
        try {
          expectEquals([[equalObject1, notEqualObject1]]);
          fail("Should get not equal to equal object error");
        } catch (e) {
          expect(e.toString(), "$equalObject1 [group 1, item 1] must be "
            "Object#equals to $notEqualObject1 [group 1, item 2]");
        }
      });

      test('Test EqualsTester with no equals or not equals objects. This checks'
        ' proper handling of null, incompatible class and reflexive tests', () {
        expectEquals([[reference]]);
      });

      test('Test EqualsTester after populating equalObjects. This checks proper'
        ' handling of equality and verifies hashCode for valid objects', () {
        expectEquals([[reference, equalObject1, equalObject2]]);
      });

      test('Test proper handling of case where an object is not equal to itself'
          , () {
        Object obj = new _NonReflexiveObject();
        try {
          expectEquals([[obj]]);
          fail("Should get non-reflexive error");
        } catch (e) {
          expect(e.toString(),
              contains("$obj must be Object#equals to itself"));
        }
      });

      test('Test proper handling where an object incorrectly tests for an '
       'incompatible class', () {
        Object obj = new _InvalidEqualsIncompatibleClassObject();
        try {
          expectEquals([[obj]]);
          fail("Should get equal to incompatible class error");
        } catch (e) {
          expect(e.toString(), contains("$obj must not be Object#equals to an "
              "arbitrary object of another class"));
        }
      });

      test('Test proper handling where an object is not equal to one the user '
        'has said should be equal', () {
        try {
          expectEquals([[reference, notEqualObject1]]);
          fail("Should get not equal to equal object error");
        } catch (e) {
          expect(e.toString(), contains("$reference [group 1, item 1]"));
          expect(e.toString(), contains("$notEqualObject1 [group 1, item 2]"));
        }
      });


      test('Test for an invalid hashCode method, i.e., one that returns '
           'different value for objects that are equal according to the equals '
            'method', () {
        Object a = new _InvalidHashCodeObject(1, 2);
        Object b = new _InvalidHashCodeObject(1, 2);
        try {
          expectEquals([[a, b]]);
          fail("Should get invalid hashCode error");
        } catch (e) {
          expect(
              e.toString(), contains("the Object#hashCode (${a.hashCode}) of $a"
              " [group 1, item 1] must be equal to the Object#hashCode ("
              "${b.hashCode}) of $b"));
        }
      });

      test('Symmetry Broken', () {
        try {
          expectEquals([[named('foo')..addPeers(['bar']), named('bar')]]);
          fail("should fail because symmetry is broken");
        } catch (e) {
          expect(e.toString(), contains('bar [group 1, item 2] must be '
              'Object#equals to foo [group 1, item 1]'));
        }
      });

      test('Transitivity Broken In EqualityGroup', () {
        try {
          expectEquals([[named('foo')..addPeers(['bar', 'baz']),
              named('bar')..addPeers(['foo']),
              named('baz')..addPeers(['foo'])]]);
          fail("should fail because transitivity is broken");
        } catch (e) {
          expect(e.toString(), contains('bar [group 1, item 2] must be '
            'Object#equals to baz [group 1, item 3]'));
        }
      });

      test('Unequal Objects In EqualityGroup', () {
        try {
          expectEquals([[named('foo'), named('bar')]]);
          fail('should fail because of unequal objects in the same equality '
                'group');
        } catch (e) {
          expect(e.toString(), contains('foo [group 1, item 1] must be '
            'Object#equals to bar [group 1, item 2]'));
        }
      });

      test('Transitivity Broken Across EqualityGroups', () {
        try {
          expectEquals([[named('foo')..addPeers(['bar']),
                                named('bar')..addPeers(['foo', 'x'])],
                                [named('baz')..addPeers(['x']),
                                named('x')..addPeers(['baz', 'bar'])]]);
          fail('should fail because transitivity is broken');
        } catch (e) {
          expect(e.toString(), contains('bar [group 1, item 2] must not be '
              'Object#equals to x [group 2, item 2]'));
        }
      });

      test('EqualityGroups', () {
        expectEquals([[
            named('foo').addPeers(['bar']), named('bar').addPeers(['foo'])],
            [named('baz'), named('baz')]]);
      });
  });
}

/// Test class that violates reflexitivity.  It is not equal to itself
class _NonReflexiveObject {
  @override
  bool operator ==(Object o) => false;

  @override
  int get hashCode => super.hashCode;
}

/**
 * Test class with valid equals and hashCode methods.  Testers created
 * with instances of this class should always pass.
 */
class _ValidTestObject {
  int aspect1;
  int aspect2;

  _ValidTestObject(this.aspect1, this.aspect2);

  @override
  bool operator ==(Object o) {
    if (!(o is _ValidTestObject)) {
      return false;
    }
    _ValidTestObject other = o as _ValidTestObject;
    if (aspect1 != other.aspect1) {
      return false;
    }
    if (aspect2 != other.aspect2) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + aspect1;
    result = 37 * result + aspect2;
    return result;
  }
}


///Test class that returns true even if the test object is of the wrong class
class _InvalidEqualsIncompatibleClassObject {
  @override
  bool operator ==(Object o) {
    return true;
  }

  @override
  int get hashCode => 0;
}

/// Test class with invalid hashCode method.
class _InvalidHashCodeObject {
  int _aspect1;
  int _aspect2;

  _InvalidHashCodeObject(this._aspect1, this._aspect2);

  @override
  bool operator ==(Object o) {
    if (!(o is _InvalidHashCodeObject)) {
      return false;
    }
    _InvalidHashCodeObject other = o as _InvalidHashCodeObject;
    if (_aspect1 != other._aspect1) return false;
    if (_aspect2 != other._aspect2) return false;
    return true;
  }
}

_NamedObject named(String name) => new _NamedObject(name);

class _NamedObject {
  final Set<String> peerNames = new Set();
  final String name;

  _NamedObject(this.name);

  void addPeers(List<String> names) {
    peerNames.addAll(names);
  }

  @override
  bool operator ==(Object obj) {
    if (obj is _NamedObject) {
      _NamedObject that = obj;
      return name == that.name || peerNames.contains(that.name);
    }
    return false;
  }

  @override
  int get hashCode => 0;

  @override String toString() => name;
}