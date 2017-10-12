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

part of quiver.async;

/// Returns the concatentation of the input streams.
///
/// When the returned stream is listened to, the [streams] are iterated through
/// asynchronously, forwarding all events (both data and error) for the current
/// stream to the returned stream before advancing the iterator and listening
/// to the next stream.  If advancing the iterator throws an error, the
/// returned stream ends immediately with that error.
///
/// Pausing and resuming the returned stream's subscriptions will pause and
/// resume the subscription of the current stream being listened to.
///
/// Note: Events from pre-existing broadcast streams which occur before the
/// stream is reached by the iteration will be dropped.
///
/// Example:
///
///     concat(files.map((file) =>
///         file.openRead().transform(const LineSplitter())))
Stream<T> concat<T>(Iterable<Stream<T>> streams) => new _ConcatStream(streams);

class _ConcatStream<T> extends Stream<T> {
  final Iterable<Stream<T>> _streams;

  _ConcatStream(Iterable<Stream<T>> streams) : _streams = streams;

  StreamSubscription<T> listen(void onData(T data),
      {Function onError, void onDone(), bool cancelOnError}) {
    cancelOnError = true == cancelOnError;
    StreamSubscription<T> currentSubscription;
    StreamController<T> controller;
    final iterator = _streams.iterator;

    void nextStream() {
      bool hasNext;
      try {
        hasNext = iterator.moveNext();
      } catch (e, s) {
        controller
          ..addError(e, s)
          ..close();
        return;
      }
      if (hasNext) {
        currentSubscription = iterator.current.listen(controller.add,
            onError: controller.addError,
            onDone: nextStream,
            cancelOnError: cancelOnError);
      } else {
        controller.close();
      }
    }

    controller = new StreamController<T>(onPause: () {
      if (currentSubscription != null) currentSubscription.pause();
    }, onResume: () {
      if (currentSubscription != null) currentSubscription.resume();
    }, onCancel: () {
      if (currentSubscription != null) return currentSubscription.cancel();
    });

    nextStream();

    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
