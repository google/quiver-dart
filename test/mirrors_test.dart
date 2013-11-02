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

library quiver.mirrors_test;

import 'dart:collection';
import 'dart:mirrors';

import 'package:quiver/mirrors.dart';
import 'package:unittest/unittest.dart';

main() {
  group('getTypeName', () {
    test('should return the qualified name for a type', () {
      expect(getTypeName(Object), const Symbol('dart.core.Object'));
      expect(getTypeName(Foo), const Symbol('quiver.mirrors_test.Foo'));
    });
  });

  group('implements', () {
    test('should return true if an object implements an interface', () {
      var foo = new Foo();
      expect(implements(foo, Object), true);
      expect(implements(foo, Foo), true);
      expect(implements(foo, Comparable), true);
      expect(implements(foo, Iterable), true);
    });

    test("should return false if an object doesn't implement an interface", () {
      var foo = new Foo();
      expect(implements(foo, String), false);
      expect(implements(foo, num), false);
    });

  });

  group('classImplements', () {
    test('should return true if an class implements an interface', () {
      var foo = new Foo();
      var mirror = reflect(foo).type;
      expect(classImplements(mirror, getTypeName(Object)), true);
      expect(classImplements(mirror, getTypeName(Foo)), true);
      expect(classImplements(mirror, getTypeName(Comparable)), true);
      expect(classImplements(mirror, getTypeName(Iterable)), true);
    });

    test("should return false if an object doesn't implement an interface", () {
      var foo = new Foo();
      var mirror = reflect(foo).type;
      expect(classImplements(mirror, getTypeName(String)), false);
      expect(classImplements(mirror, getTypeName(num)), false);
    });

  });

  group('getMemberMirror', () {
    test('should return a member of a class', () {
      var mirror = reflect(new Foo()).type;
      expect(getDeclaration(mirror, const Symbol('toString')),
          new isInstanceOf<MethodMirror>());
      expect(getDeclaration(mirror, const Symbol('a')),
          new isInstanceOf<VariableMirror>());
    });
  });

  group('Method', () {
    test('should be callable', () {
      var i = 2;
      var mirror = reflect(i);
      var method = new Method(mirror, const Symbol('+'));
      expect(method(3), 5);
    });

    test('should be callable with named arguments', () {
      // this test will fail when named argument support is added
      var i = [1, 2];
      var mirror = reflect(i);
      var method = new Method(mirror, const Symbol('toList'));
      expect(method(growable: false), [1, 2]);
    });

  });
}

class Foo extends IterableBase implements Comparable {
  String a;
  get iterator => null;
  int compareTo(o) => 0;
}
