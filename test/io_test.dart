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

library quiver.io_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:quiver/io.dart';
import 'package:unittest/unittest.dart';

main() {
  group('byteStreamToString', () {
    test('should decode UTF8 text by default', () {
      var string = '箙、靫';
      var encoded = UTF8.encoder.convert(string);
      var data = [encoded.sublist(0, 3), encoded.sublist(3)];
      var stream = new Stream.fromIterable(data);
      byteStreamToString(stream).then((decoded) {
        expect(decoded, string);
      });
    });

    test('should decode text with the specified encoding', () {
      var string = 'blåbærgrød';
      var encoded = LATIN1.encoder.convert(string);
      var data = [encoded.sublist(0, 4), encoded.sublist(4)];
      var stream = new Stream.fromIterable(data);
      byteStreamToString(stream, encoding: LATIN1).then((decoded) {
        expect(decoded, string);
      });
    });
  });

  group('visitDirectory', () {
    var testPath;
    var testDir;

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
      new File(path.join(testPath, 'file_target')).createSync();
      new Directory(path.join(testPath, 'dir_target')).createSync();
      new File(path.join(testPath, 'dir_target/file')).createSync();
      new Link(path.join(testPath, 'file_link')).createSync('file_target');
      new Link(path.join(testPath, 'dir_link')).createSync('dir_target');
      new Link(path.join(testPath, 'broken_link')).createSync('broken_target');

      var results = [];

      visitDirectory(testDir, (FileSystemEntity e) {
        if (e is File) {
          results.add("file: ${e.path}");
        } else if (e is Directory) {
          results.add("dir: ${e.path}");
        } else if (e is Link) {
          results.add("link: ${e.path}, ${e.targetSync()}");
        } else {
          throw "bad";
        }
        return new Future.value(true);
      }).then(expectAsync1((_) {
        var testPathFull = new File(testPath).absolute.path;
        var expectation = [
         "file: $testPath/file_target",
         "dir: $testPath/dir_target",
         "file: $testPath/dir_target/file",
         "link: $testPath/file_link, file_target",
         "link: $testPath/dir_link, dir_target",
         "file: $testPath/dir_link/file",
         "link: $testPath/broken_link, broken_target",
         ];
        expect(results, unorderedEquals(expectation));
      }));
    });

    test('should conditionally recurse sub-directories', () {
      new Directory(path.join(testPath, 'dir')).createSync();
      new File(path.join(testPath, 'dir/file')).createSync();
      new Directory(path.join(testPath, 'dir2')).createSync();
      new File(path.join(testPath, 'dir2/file')).createSync();

      var files = [];
      visitDirectory(testDir, (e) {
        files.add(e);
        return new Future.value(!e.path.endsWith('dir2'));
      }).then(expectAsync1((_) {
        expect(files.map((e) => e.path), unorderedEquals([
            "$testPath/dir",
            "$testPath/dir/file",
            "$testPath/dir2",
        ]));
      }));
    });

    test('should not infinitely recurse on symlink cycles', () {
      var dir = new Directory(path.join(testPath, 'dir'))..createSync();
      new Link(path.join(testPath, 'dir/link')).createSync('../dir');
      var files = [];
      visitDirectory(dir, (e) {
        files.add(e);
        return new Future.value(true);
      }).then(expectAsync1((_) {
        expect(files.length, 1);
        expect(files.first.targetSync(), '../dir');
      }));
    });
  });
}
