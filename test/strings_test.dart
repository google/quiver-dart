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

library quiver.strings;

import 'package:quiver/strings.dart';
import 'package:unittest/unittest.dart';

main() {
  group('isBlank', () {
    test('should consider null a blank', () {
      expect(isBlank(null), isTrue);
    });
    test('should consider empty string a blank', () {
      expect(isBlank(''), isTrue);
    });
    test('should consider white-space-only string a blank', () {
      expect(isBlank(' \n\t\r\f'), isTrue);
    });
    test('should consider non-whitespace string not a blank', () {
      expect(isBlank('hello'), isFalse);
    });
  });

  group('flip', () {
    test('should flip characters in a string', () {
      expect(flip('ab'), 'ba');
    });
    test('should return null as null', () {
      expect(flip(null), null);
    });
    test('should return empty string as empty string', () {
      expect(flip(''), '');
    });
  });

  group('nullToEmpty', () {
    test('should turn null to empty string', () {
      expect(nullToEmpty(null), '');
    });
    test('should leave non-null string unchanged', () {
      expect(nullToEmpty('hi!'), 'hi!');
    });
    test('should leave empty string unchanged', () {
      expect(nullToEmpty(''), '');
    });
  });

  group('emptyToNull', () {
    test('should turn empty string to null', () {
      expect(emptyToNull(''), null);
    });
    test('should leave non-null string unchanged', () {
      expect(emptyToNull('hi!'), 'hi!');
    });
    test('should leave null as null', () {
      expect(emptyToNull(null), null);
    });
  });

  group('repeat', () {
    test('should repeat a non-empty string', () {
      expect(repeat('ab', 3), 'ababab');
    });
    test('should repeat flipped non-empty string '
         'on negative number of times', () {
      expect(repeat('ab', -3), 'bababa');
    });
    test('should return null on null', () {
      expect(repeat(null, 6), null);
      expect(repeat(null, -6), null);
    });
    test('should return empty string on empty string', () {
      expect(repeat('', 6), '');
      expect(repeat('', -6), '');
    });
  });

  group('loop', () {
    // Forward direction test cases
    test('should work like normal substring', () {
      expect(loop('hello', 1, 3), 'el');
    });
    test('should work like normal substring full-string', () {
      expect(loop('hello', 0, 5), 'hello');
    });
    test('should be circular', () {
      expect(loop('ldwor', -3, 2), 'world');
    });
    test('should be circular over many loops', () {
      expect(loop('ab', 0, 8), 'abababab');
    });
    test('should be circular over many loops starting loops away', () {
      expect(loop('ab', 4, 12), 'abababab');
    });
    test('should be circular over many loops starting mid-way', () {
      expect(loop('ab', 1, 9), 'babababa');
    });
    test('should be circular over many loops starting mid-way loops away', () {
      expect(loop('ab', 5, 13), 'babababa');
    });
    test('should default to end of string', () {
      expect(loop('hello', 3), 'lo');
    });
    test('should default to end of string from negative index', () {
      expect(loop('/home/user/test.txt', -3), 'txt');
    });
    test('should default to end of string from far negative index', () {
      expect(loop('ab', -5), 'b');
    });
    test('should handle in-fragment substring loops away negative', () {
      expect(loop('hello', -4, -2), 'el');
    });
    test('should handle in-fragment substring loops away positive', () {
      expect(loop('hello', 6, 8), 'el');
    });

    // Backward direction test cases
    test('should traverse backwards', () {
      expect(loop('hello', 3, 0), 'leh');
    });
    test('should traverse backwards across boundary', () {
      expect(loop('eholl', 2, -3), 'hello');
    });
    test('should traverse backwards many loops', () {
      expect(loop('ab', 0, -6), 'bababa');
    });

    // Corner cases
    test('should throw on null', () {
      expect(() => loop(null, 6, 8), throws);
    });
    test('should throw on empty', () {
      expect(() => loop('', 6, 8), throws);
    });
  });
}
