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

part of quiver.testing.matchers;

/// A drop-in replacement for [isInstanceOf]. Unlike [isInstanceOf] this
/// matcher fails if the type parameter is malformed, e.g. when it is not
/// imported or contains a typo. This class does not support matching on
/// [Object] or `dynamic`.
class isAssignableTo<T> extends Matcher {

  String _name;
  final _delegate = new isInstanceOf<T>();

  isAssignableTo([name = 'specified type']) {
    _name = name;
    try {
      expect(new Object(), isNot(_delegate));
    } on TestFailure catch(f) {
      throw new ArgumentError(
          'Seems like an unsupported type was passed to '
          'isAssignableTo. Three known possibilities:\n'
          ' - You are trying to check Object/dynamic\n'
          ' - The type does not exist\n'
          ' - The type exists but you forgot to import it');
    }
  }

  Description describe(Description description) =>
  description.add('assignable to ${_name}');

  bool matches(item, Map matchState) =>
  _delegate.matches(item, matchState);
}
