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

library quiver.log.appender_test;

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:quiver/log.dart';
import 'package:unittest/unittest.dart';

main() {
  group('Appender', (){
     test('Appends handles log message and formats before output', (){
       var appender = new InMemoryListAppender(new SimpleStringFormatter());
       var logger = new SimpleLogger();
       appender.attachLogger(logger);

       logger.info('test message');

       expect(appender.messages.last, 'Formatted test message');
     });
  });
}

class SimpleLogger implements Logger {
  StreamController<LogRecord> _controller = new StreamController(sync:true);
  Stream<LogRecord> get onRecord => _controller.stream;

  void info(String msg, [exception]) =>
    _controller.add(new LogRecord(Level.INFO, msg, 'simple'));

  dynamic noSuchMethod(Invocation i) {}
}

class SimpleStringFormatter extends StringFormatter {
  String format(LogRecord record) => "Formatted ${record.message}";
}