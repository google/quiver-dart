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

/// Simple code with broad use cases.
library quiver.core;

import 'dart:collection';

part 'src/core/hash.dart';
part 'src/core/optional.dart';

/// Returns the first non-null argument. If all arguments are null, throws an
/// [ArgumentError].
///
/// Note: if [o1] is an [Optional], this can be accomplished with `o1.or(o2)`.
firstNonNull(o1, o2, [o3, o4]) {
  if (o1 != null) return o1;
  if (o2 != null) return o2;
  if (o3 != null) return o3;
  if (o4 != null) return o4;
  throw new ArgumentError('All arguments were null');
}
