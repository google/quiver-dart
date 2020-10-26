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

/// Asserts that the current runtime has checked mode enabled.
///
/// Otherwise, throws [StateError].
@Deprecated('Checked mode is meaningless in Dart 2.0. Will be removed in 3.0.0')
void assertCheckedMode() {
  _isCheckedMode ??= _checkForCheckedMode();

  if (!_isCheckedMode) {
    throw StateError('Not in checked mode.');
  }
}

bool _isCheckedMode;

bool _checkForCheckedMode() {
  Object sentinal = Object();
  try {
    var i = 1 as dynamic;
    _takeString(i);
    throw sentinal;
  } catch (e) {
    if (e == sentinal) return false;
  }
  return true;
}

void _takeString(String value) {}
