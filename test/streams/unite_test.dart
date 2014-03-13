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

library quiver.streams.unite_test;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:quiver/streams.dart';
import 'package:quiver/iterables.dart' as iterables;

main() {
  group('unite', () {

    test('should produce no events for no streams', () =>
        unite([]).toList().then((events) => expect(events, isEmpty)));

    test('should echo events of a single stream', () {
      var controller = new StreamController<String>();
      var united = unite([controller.stream]);
      var expectation = united.toList().then((e) {
        expect(e, ['a', 'b', 'c']);
      });
      ['a', 'b', 'c'].forEach(controller.add);
      return Future.wait([controller.close(), expectation]);
    });

    test('should handle empty streams', () {
      var united = unite([new Stream.fromIterable([])]);
      return united.toList().then((e) {
        expect(e, []);
      });
    });

    test('should forward events from multiple streams as they happen', () {
      var controller1 = new StreamController<String>(sync: true);
      var controller2 = new StreamController<String>(sync: true);
      var united = unite([controller1.stream, controller2.stream]);
      var events = [];

      var subscription = united.listen(events.add, onError: events.add);

      controller1.add('a');
      controller2.add('b');
      controller1.addError('c');
      controller2.add('d');
      controller2.addError('e');
      controller1.add('f');

      Timer.run(() {
        Future.wait([controller1.close(), controller2.close()]).then((_) {
          expect(events, ['a', 'b', 'c', 'd', 'e', 'f']);
        });
      });
    });

    test('should forward pause, resume, and cancel to each stream', () {

      var controllers = <StreamController> [];
      var pausedLog = <StreamController, bool> {};
      var resumedLog = <StreamController, bool> {};
      var canceledLog = <StreamController, bool> {};

      iterables.range(2).forEach((i) {
        StreamController controller;
        controller = new StreamController<String>(
          onPause: () => pausedLog[controller] = true,
          onResume: () => resumedLog[controller] = true,
          onCancel: () => canceledLog[controller] = true);
        controllers.add(controller);
        pausedLog[controller] = false;
        resumedLog[controller] = false;
        canceledLog[controller] = false;
      });

      var united = unite(controllers.map((controller) => controller.stream));

      var subscription = united.listen(null);

      addToAll(event) {
        controllers.forEach((controller) => controller.add(event));
      }

      expectLogsTrue(log, name) {
        allTrue(iterable) => iterable.every((i) => i == true);
        expect(allTrue(log.values), isTrue, reason: 'not all $name');
      }

      addToAll('a');

      return new Future.value()
          .then((_) => subscription.pause())
          .then((_) => expectLogsTrue(pausedLog, 'paused'))
          .then((_) => subscription.resume())
          // Give resume a chance to take effect.
          .then((_) => addToAll('b'))
          .then((_) => new Future(subscription.cancel))
          .then((_) => expectLogsTrue(resumedLog, 'resumed'))
          .then((_) => expectLogsTrue(canceledLog, 'canceled'))
          .then((_) => controllers.forEach((controller) => controller.close()));
    });

  });
}