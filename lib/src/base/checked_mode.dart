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

part of quiver.base;

/**
 * Whether the current environment is doing runtime type checks.
 */
bool get isCheckedMode {
  if (_isCheckedMode == null) _isCheckedMode = _checkForCheckedMode();

  return _isCheckedMode;
}

bool _isCheckedMode = null;

bool _checkForCheckedMode() {
  Object sentinal = new Object();
  try {
    String string = 1;
    throw sentinal;
  } catch (e) {
    if (e == sentinal) return false;
  }
  return true;
}
