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

part of quiver.testing.async;

/**
 * A [Timer] implementation that stores its duration and callback for access
 * in tests.
 */
class FakeTimer implements Timer {
  Duration duration;
  var callback;
  var onCancel;

  /**
   * Sets this timers [duration] and [callback] and returns [this].
   *
   * This method is usable as a [CreateTimer] or [CreateTimerPeriodic]
   * function. In tests, construct a FakeTimer so that you have a refernece to
   * it, then pass [create] to the function or class under test.
   */
  FakeTimer create(Duration duration, callback) {
    if (this.duration != null) {
      throw new StateError("FakeTimer.create already called");
    }
    this.duration = duration;
    this.callback = callback;
    return this;
  }

  void cancel() {
    if (onCancel != null) onCancel();
  }

  bool isActive = true;
}
