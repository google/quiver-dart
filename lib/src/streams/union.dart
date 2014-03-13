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

part of quiver.streams;

/**
 * Returns the union of the input streams.
 *
 * When the returned stream is listened to, each of the [streams] are listened
 * to, forwarding all events (both data and error) to the returned stream.
 *
 * Pausing and resuming the returned stream's subscriptions will pause and
 * resume the subscriptions of each of the [streams].
 *
 * Example:
 *
 *     union(buttons.map((el) => el.onClick)).forEach(handleClick);
 *
 */
Stream union(Iterable<Stream> streams) => new _UnionStream(streams);

class _UnionStream extends Stream {

  final Iterable<Stream> _streams;

  _UnionStream(this._streams);

  StreamSubscription listen(void onData(List data), {
                                  Function onError,
                                  void onDone(),
                                  bool cancelOnError}) {
    cancelOnError = true == cancelOnError;
    List<StreamSubscription> subscriptions = <StreamSubscription>[];
    StreamController controller;

    cancelSubscriptions() {
      subscriptions.forEach((subscription) => subscription.cancel());
    }

    void handleErrorCancel(Object error, StackTrace stackTrace) {
      cancelSubscriptions();
      controller.addError(error, stackTrace);
    }

    checkDone() {
      if(subscriptions.isEmpty) controller.close();
    }

    void handleDone(StreamSubscription subscription) {
      subscriptions.remove(subscription);
      checkDone();
    }

    controller = new StreamController(
      onPause: () {
        subscriptions.forEach((subscription) => subscription.pause());
      },
      onResume: () {
        subscriptions.forEach((subscription) => subscription.resume());
      },
      onCancel: () {
        cancelSubscriptions();
      }
    );

    try {
      for (var stream in _streams) {
        StreamSubscription subscription;
        subscription = stream.listen(
            controller.add,
            onError: cancelOnError ? handleErrorCancel : controller.addError,
            onDone: () => handleDone(subscription),
            cancelOnError: cancelOnError);
        subscriptions.add(subscription);
      }
    } catch (e) {
      cancelSubscriptions();
      rethrow;
    }

    checkDone();

    return controller.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError);
  }
}