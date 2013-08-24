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

library quiver.mirrors;

import 'dart:mirrors';

/**
 * Returns the qualified name of [t].
 */
Symbol getTypeName(Type t) => reflectClass(t).qualifiedName;


/**
 * Returns true if [o] implements [type].
 */
bool implements(Object o, Type type) =>
    classImplements(reflect(o).type, getTypeName(type));

/**
 * Returns true if [m], its superclasses or interfaces have the qualified name
 * [name].
 */
bool classImplements(ClassMirror m, Symbol name) {
  if (m == null) return false;
  if (m.qualifiedName == name) return true;
  if (m.qualifiedName == const Symbol('dart.core.Object')) return false;
  if (classImplements(m.superclass, name)) return true;
  if (m.superinterfaces.any((i) => classImplements(i, name))) return true;
  return false;
}

/**
 * Walks up the class hierarchy to find a method declaration with the given
 * [name].
 *
 * Note that it's not possible to tell if there's an implementation via
 * noSuchMethod().
 */
Mirror getMemberMirror(ClassMirror classMirror, Symbol name) {
  if (classMirror.members.containsKey(name)) {
    return classMirror.members[name];
  }
  if (classMirror.superclass != null) {
    var mirror = getMemberMirror(classMirror.superclass, name);
    if (mirror != null) {
      return mirror;
    }
  }
  for (ClassMirror supe in classMirror.superinterfaces) {
    var mirror = getMemberMirror(supe, name);
    if (mirror != null) {
      return mirror;
    }
  }
  return null;
}

/**
 * Closurzes a method reflectively.
 */
class Method { // implements Function
  final InstanceMirror mirror;
  final Symbol symbol;

  Method(this.mirror, this.symbol);

  dynamic noSuchMethod(Invocation i) {
    if (i.isMethod && i.memberName == const Symbol('call')) {
      if (i.namedArguments != null && i.namedArguments.isNotEmpty) {
        // this will fail until named argument support is implemented
        return mirror.invoke(symbol, i.positionalArguments, i.namedArguments)
            .reflectee;
      }
      return mirror.invoke(symbol, i.positionalArguments).reflectee;
    }
    return super.noSuchMethod(i);
  }
}
