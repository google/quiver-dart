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

/// Generates a hash code for multiple [objects].
@Deprecated('Use Object.hashAll instead')
int hashObjects(Iterable objects) => Object.hashAll(objects);

/// Generates a hash code for two objects.
@Deprecated('Use Object.hash instead')
int hash2(a, b) => Object.hash(a, b);

/// Generates a hash code for three objects.
@Deprecated('Use Object.hash instead')
int hash3(a, b, c) => Object.hash(a, b, c);

/// Generates a hash code for four objects.
@Deprecated('Use Object.hash instead')
int hash4(a, b, c, d) => Object.hash(a, b, c, d);
