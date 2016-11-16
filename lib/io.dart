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

library quiver.io;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:quiver/async.dart';

///  Converts a [Stream] of byte lists to a [String].
Future<String> byteStreamToString(Stream<List<int>> stream,
    {Encoding encoding: UTF8}) {
  return stream.transform(encoding.decoder).join();
}

/// Gets the full path of [path] by using [File.fullPathSync].
String getFullPath(path) => new File(path).resolveSymbolicLinksSync();

/// Lists the sub-directories and files of this Directory, optionally recursing
/// into sub-directories based on the return value of [visit].
///
/// [visit] is called with a [File], [Directory] or [Link] to a directory,
/// never a Symlink to a File. If [visit] returns true, then it's argument is
/// listed recursively.
Future visitDirectory(Directory dir, Future<bool> visit(FileSystemEntity f)) {
  var futureGroup = new FutureGroup();

  void _list(Directory dir) {
    var completer = new Completer();
    futureGroup.add(completer.future);
    dir.list(followLinks: false).listen((FileSystemEntity entity) {
      var future = visit(entity);
      if (future != null) {
        futureGroup.add(future.then((bool recurse) {
          // recurse on directories, but not cyclic symlinks
          if (entity is! File && recurse == true) {
            if (entity is Link) {
              if (FileSystemEntity.typeSync(entity.path, followLinks: true) ==
                  FileSystemEntityType.DIRECTORY) {
                var fullPath = getFullPath(entity.path).toString();
                var dirFullPath = getFullPath(dir.path).toString();
                if (!dirFullPath.startsWith(fullPath)) {
                  _list(new Directory(entity.path));
                }
              }
            } else {
              _list(entity);
            }
          }
        }));
      }
    }, onDone: () {
      completer.complete(null);
    }, cancelOnError: true);
  }

  _list(dir);

  return futureGroup.future;
}
