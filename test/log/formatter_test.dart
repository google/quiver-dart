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

library quiver.log.formatter_test;

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:quiver/log.dart';
import 'package:unittest/unittest.dart';

main() {
  group('CommonLogFormatter', (){
     test('correctly formats LogRecord', (){
       LogRecord record =
           new LogRecord(Level.INFO, 'formatted message!', 'root');
       var dateFormat = new DateFormat("MMyy H:m:s.S");
       expect(COMMON_LOG_FORMATTER.format(record),
           'INFO ${dateFormat.format(record.time)} 0 root formatted message!');
     });
  });
}