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

// ignore_for_file: deprecated_member_use_from_same_package
@TestOn('vm')
library quiver.io_test;

import 'dart:async';
import 'dart:convert' show latin1, utf8;
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:quiver/io.dart';
import 'package:test/test.dart';

void main() {
  group('byteStreamToString', () {
    test('should decode UTF8 text by default', () {
      var string = '箙、靫';
      var encoded = utf8.encoder.convert(string);
      var data = [encoded.sublist(0, 3), encoded.sublist(3)];
      var stream = Stream<List<int>>.fromIterable(data);
      byteStreamToString(stream).then((decoded) {
        expect(decoded, string);
      });
    });

    test('should decode text with the specified encoding', () {
      var string = 'blåbærgrød';
      var encoded = latin1.encoder.convert(string);
      var data = [encoded.sublist(0, 4), encoded.sublist(4)];
      var stream = Stream<List<int>>.fromIterable(data);
      byteStreamToString(stream, encoding: latin1).then((decoded) {
        expect(decoded, string);
      });
    });
  });

  group('visitDirectory', () {
    Directory testDir;
    String testPath;

    setUp(() {
      testDir = Directory.systemTemp.createTempSync();
      testPath = testDir.path;
    });

    tearDown(() {
      if (testDir.existsSync()) testDir.deleteSync(recursive: true);
    });

    /*
     * Tests listing 7 cases of files, directories and links:
     *   1. A file
     *   2. A directory
     *   3. A file in a directory
     *   4. A link to a file
     *   5. A link to a directory
     *   6  A file in a directory, reached by a link to that directory
     *   7. A broken link
     */
    test('should handle symlinks', () {
      File(path.join(testPath, 'file_target')).createSync();
      Directory(path.join(testPath, 'dir_target')).createSync();
      File(path.join(testPath, 'dir_target/file')).createSync();
      Link(path.join(testPath, 'file_link')).createSync('file_target');
      Link(path.join(testPath, 'dir_link')).createSync('dir_target');
      Link(path.join(testPath, 'broken_link')).createSync('broken_target');

      var results = [];

      return visitDirectory(testDir, (FileSystemEntity e) {
        if (e is File) {
          results.add('file: ${e.path}');
        } else if (e is Directory) {
          results.add('dir: ${e.path}');
        } else if (e is Link) {
          results.add('link: ${e.path}, ${e.targetSync()}');
        } else {
          throw 'bad';
        }
        return Future.value(true);
      }).then((_) {
        var expectation = [
          'file: $testPath/file_target',
          'dir: $testPath/dir_target',
          'file: $testPath/dir_target/file',
          'link: $testPath/file_link, file_target',
          'link: $testPath/dir_link, dir_target',
          'file: $testPath/dir_link/file',
          'link: $testPath/broken_link, broken_target',
        ];
        expect(results, unorderedEquals(expectation));
      });
    });

    test('should conditionally recurse sub-directories', () {
      Directory(path.join(testPath, 'dir')).createSync();
      File(path.join(testPath, 'dir/file')).createSync();
      Directory(path.join(testPath, 'dir2')).createSync();
      File(path.join(testPath, 'dir2/file')).createSync();

      var files = [];
      return visitDirectory(testDir, (e) {
        files.add(e);
        return Future.value(!e.path.endsWith('dir2'));
      }).then((_) {
        expect(
            files.map((e) => e.path),
            unorderedEquals([
              '$testPath/dir',
              '$testPath/dir/file',
              '$testPath/dir2',
            ]));
      });
    });

    test('should not infinitely recurse on symlink cycles', () {
      var dir = Directory(path.join(testPath, 'dir'))..createSync();
      Link(path.join(testPath, 'dir/link')).createSync('../dir');
      var files = [];
      return visitDirectory(dir, (e) {
        files.add(e);
        return Future.value(true);
      }).then((_) {
        expect(files.length, 1);
        expect(files.first.targetSync(), '../dir');
      });
    });
  });
}
