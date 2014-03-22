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
 * Allow orderly reading of elements from a datastream, such as Socket, which
 * might not receive List<int> bytes regular chunks.
 *
 * Example usage:
 *     StreamBuffer<int> buffer = new StreamBuffer();
 *     Socket.connect('127.0.0.1', 5555).then((sock) => sock.pipe(buffer));
 *     buffer.read(100).then((bytes) {
 *       // do something with 100 bytes;
 *     });
 */
class StreamBuffer<T> implements StreamConsumer<T> {

  List<List<T>> _chunks = [];
  int _offset = 0;
  int _counter = 0; // sum(_chunks[*].length) - _offset
  List<_ReaderInWaiting<T>> _readers = [];
  StreamSubscription<T> _sub;
  Completer _streamDone;

  final int limit;

  /**
   * Create a stream buffer with optional, soft [limit] to the amount of data
   * the buffer will hold before pausing the underlying straem. A limit of 0
   * means no buffer limits.
   */
  StreamBuffer({this.limit: 0});

  /**
   * The amount of unread data buffered.
   */
  int get buffered => _counter;

  List<T> _consume(int size) {
    // Check if we can short-circuit the the process with one list.
    var follower = 0;
    var ret = new List(size);
    while (size > 0) {
      var list = _chunks.first;
      var listCap = list.length - _offset;
      var subsize = size > listCap ? listCap : size;
      ret.setRange(follower, follower + subsize,
          list.getRange(_offset, _offset + subsize));
      follower += subsize;
      _offset += subsize;
      _counter -= subsize;
      size -= subsize;
      if (_offset >= list.length) {
        _offset = 0;
        _chunks.removeAt(0);
      }
    }
    if (_sub.isPaused && limit > 0 && _counter < limit) {
      _sub.resume();
    }
    return ret;
  }

  /**
   * Read fully [size] bytes from the stream and return in the future.
   *
   * Throws [ArgumentError] if size is larger than optional buffer [limit].
   */
  Future<List<T>> read(int size) {
    // If we have enough data to consume and there are no other readers, then
    // we can return immediately.
    if (limit > 0 && size > limit) {
      throw new ArgumentError("Cannot read $size with limit $limit");
    }

    if (size <= buffered && _readers.isEmpty) {
      return new Future.value(_consume(size));
    }
    Completer completer = new Completer<List<T>>();
    _readers.add(new _ReaderInWaiting(size, completer));
    return completer.future;
  }

  Future addStream(Stream<T> stream) {
    if (_sub != null) {
      _sub.cancel();
      _streamDone.complete();
    }
    Completer streamDone = new Completer();
    _sub = stream.listen((items) {
      _chunks.add(items);
      _counter += items.length;
      if (limit > 0 && _counter >= limit) {
        _sub.pause();
      }

      while (_readers.isNotEmpty && _readers.first.size <= _counter) {
        var waiting = _readers.removeAt(0);
        waiting.completer.complete(_consume(waiting.size));
      }
    }, onDone: () => streamDone.complete());
    return streamDone.future;
  }

  Future close() {
    var ret ;
    if (_sub != null) {
      ret = _sub.cancel();
      _sub = null;
    }
    return ret is Future ? ret : new Future.value();
  }
}

class _ReaderInWaiting<T> {
  int size;
  Completer completer;
  _ReaderInWaiting(this.size, this.completer);
}
