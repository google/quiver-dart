// Copyright 2017 Google Inc. All Rights Reserved.
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

part of quiver.async;

/// Returns a [Future] that completes when all given [Future]s complete.
///
/// Uses [Future.wait] but with removes null elements from the provided
/// `futures` iterable first.
///
/// The returned [Future<List>] will be shorter than the given `futures` if
/// it contains nulls.
Future<List<T>> waitGroup<T>(Iterable<Future<T>> futures) {
  return Future.wait(futures.where((Future<T> future) => future != null));
}
