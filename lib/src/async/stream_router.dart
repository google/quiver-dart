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

part of quiver.async;

/**
 * Splits a [Stream] of events into multiple Streams based on a set of
 * predicates.
 *
 * Using StreamRouter differs from [Stream.where] because events are only sent
 * to one Stream. If more than one predicate matches the event, the event is
 * sent to the stream created by the earlier call to [route]. Events not matched
 * by a call to [route] are sent to the [defaultStream].
 *
 * Example:
 *   import 'dart:html';
 *   import 'package:quiver/async.dart';
 *
 *   var router = new StreamRouter(window.onClick);
 *   var onRightClick = router.route((e) => e.button == 2);
 *   var onAltClick = router.route((e) => e.altKey);
 *   var onOtherClick router.defaultStream;
 */
class StreamRouter<T> {
  final Stream<T> _incoming;
  int _listenerCount = 0;
  StreamSubscription _subscription;

  final List<_Route<T>> _routes = <_Route<T>>[];
  final StreamController<T> _defaultController =
      new StreamController<T>.broadcast();

  /**
   * Create a new StreamRouter that listens to the [incoming] stream once
   * the first listener has been added to one of the child streams and stops
   * listening when the last child listener has been removed.
   */
  StreamRouter(Stream<T> incoming) : _incoming = incoming;

  /**
   * Events that match [predicate] are sent to the stream created by this
   * method, and not sent to any other router streams.
   */
  Stream<T> route(bool predicate(T event)) {
    var controller = new StreamController<T>.broadcast(
      onListen: _maybeListen,
      onCancel: _maybeCancel
    );
    _routes.add(new _Route(predicate, controller));
    return controller.stream;
  }

  Stream<T> get defaultStream => _defaultController.stream;

  Future close() {
    _subscription.cancel();
    _subscription = null;
    return Future.wait(_routes.map((r) => r.controller.close()));
  }

  void _handle(T event) {
    var route =
        _routes.firstWhere((r) => r.predicate(event), orElse: () => null);
    var controller = (route != null) ? route.controller : _defaultController;
    controller.add(event);
  }

  void _maybeCancel() {
    _listenerCount--;
    if (_listenerCount == 0) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  void _maybeListen() {
    _listenerCount++;
    if (_listenerCount == 1) {
      _subscription = _incoming.listen(_handle, onDone: close);
    }
  }
}

typedef bool _Predicate(event);

class _Route<T> {
  final _Predicate predicate;
  final StreamController<T> controller;

  _Route(this.predicate, this.controller);
}
