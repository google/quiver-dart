// Copyright 2016 Google Inc. All Rights Reserved.
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

const _defaultInterval = const Duration(milliseconds: 100);
const _defaultTimeout = const Duration(seconds: 60);

/// Runs an asynchronous [task] repeatedly until it succeeds or [timeout] is
/// reached.
///
/// Waits [interval] to perform the retry after a failed attempt.
///
/// If the task fails to complete once within the timeout it will resolve as an
/// error with a TimeoutException. If the task completes with an error at least
/// once before the timeout and never succeeds it will resolve as an error with
/// the last exception from a task run that did not time out.
Future/*<T>*/ retry/*<T>*/(Future/*<T>*/ task(),
    {Duration interval: _defaultInterval,
    Duration timeout: _defaultTimeout}) async {
  var end = new DateTime.now().add(timeout);
  dynamic lastCaught;
  while (true) {
    try {
      return await task().timeout(end.difference(new DateTime.now()));
    } on TimeoutException catch (_) {
      if (lastCaught == null) rethrow;
      throw lastCaught;
    } catch (error) {
      if (new DateTime.now().isAfter(end)) rethrow;
      await new Future<Null>.delayed(interval);
    }
  }
}
