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
import 'package:quiver/string_extensions.dart';
import 'package:test/test.dart' hide isEmpty, isNotEmpty;

void main() {
  group('isBlank', () {
    test('should consider null a blank', () {
      expect(isBlank(null), isTrue);
    });
    test('should consider empty string a blank', () {
      expect(isBlank(''), isTrue);
      expect(''.isBlank, isTrue);
    });
    test('should consider white-space-only string a blank', () {
      expect(isBlank(' \n\t\r\f'), isTrue);
      expect(' \n\t\r\f'.isBlank, isTrue);
    });
    test('should consider non-whitespace string not a blank', () {
      expect(isBlank('hello'), isFalse);
      expect('hello'.isBlank, isFalse);
    });
  });

  group('isNotBlank', () {
    test('should consider null a blank', () {
      expect(isNotBlank(null), isFalse);
    });
    test('should consider empty string a blank', () {
      expect(isNotBlank(''), isFalse);
      expect(''.isNotBlank, isFalse);
    });
    test('should consider white-space-only string a blank', () {
      expect(isNotBlank(' \n\t\r\f'), isFalse);
      expect(' \n\t\r\f'.isNotBlank, isFalse);
    });
    test('should consider non-whitespace string not a blank', () {
      expect(isNotBlank('hello'), isTrue);
      expect('hello'.isNotBlank, isTrue);
    });
  });

  group('isEmpty', () {
    test('should consider null to be empty', () {
      expect(isEmpty(null), isTrue);
    });
    test('should consider the empty string to be empty', () {
      expect(isEmpty(''), isTrue);
      expect(''.isEmpty, isTrue);
    });
    test('should consider whitespace string to be not empty', () {
      expect(isEmpty(' '), isFalse);
      expect(' '.isEmpty, isFalse);
    });
    test('should consider non-whitespace string to be not empty', () {
      expect(isEmpty('hello'), isFalse);
      expect('hello'.isEmpty, isFalse);
    });
  });

  group('isNotEmpty', () {
    test('should consider null to be empty', () {
      expect(isNotEmpty(null), isFalse);
    });
    test('should consider the empty string to be empty', () {
      expect(isNotEmpty(''), isFalse);
      expect(''.isNotEmpty, isFalse);
    });
    test('should consider whitespace string to be not empty', () {
      expect(isNotEmpty(' '), isTrue);
      expect(' '.isNotEmpty, isTrue);
    });
    test('should consider non-whitespace string to be not empty', () {
      expect(isNotEmpty('hello'), isTrue);
      expect('hello'.isNotEmpty, isTrue);
    });
  });

  group('isDigit', () {
    test('should return true for standard digits', () {
      for (var i = 0; i <= 9; i++) {
        int codeUnit = '$i'.codeUnitAt(0);

        expect(isDigit(codeUnit), isTrue);
        expect(codeUnit.isDigit, isTrue);
      }
    });
    test('should return false for non-digits', () {
      expect(isDigit('a'.codeUnitAt(0)), isFalse);
      expect('a'.codeUnitAt(0).isDigit, isFalse);

      expect(isDigit(' '.codeUnitAt(0)), isFalse);
      expect(' '.codeUnitAt(0).isDigit, isFalse);

      expect(isDigit('%'.codeUnitAt(0)), isFalse);
      expect('%'.codeUnitAt(0).isDigit, isFalse);
    });
  });

  group('loop', () {
    // Forward direction test cases
    test('should work like normal substring', () {
      expect(loop('hello', 1, 3), 'el');
      expect('hello'.loop(1, 3), 'el');
    });
    test('should work like normal substring full-string', () {
      expect(loop('hello', 0, 5), 'hello');
      expect('hello'.loop(0, 5), 'hello');
    });
    test('should be circular', () {
      expect(loop('ldwor', -3, 2), 'world');
      expect('ldwor'.loop(-3, 2), 'world');
    });
    test('should be circular over many loops', () {
      expect(loop('ab', 0, 8), 'abababab');
      expect('ab'.loop(0, 8), 'abababab');
    });
    test('should be circular over many loops starting loops away', () {
      expect(loop('ab', 4, 12), 'abababab');
      expect('ab'.loop(4, 12), 'abababab');
    });
    test('should be circular over many loops starting mid-way', () {
      expect(loop('ab', 1, 9), 'babababa');
      expect('ab'.loop(1, 9), 'babababa');
    });
    test('should be circular over many loops starting mid-way loops away', () {
      expect(loop('ab', 5, 13), 'babababa');
      expect('ab'.loop( 5, 13), 'babababa');
    });
    test('should default to end of string', () {
      expect(loop('hello', 3), 'lo');
      expect('hello'.loop(3), 'lo');
    });
    test('should default to end of string from negative index', () {
      expect(loop('/home/user/test.txt', -3), 'txt');
      expect('/home/user/test.txt'.loop(-3), 'txt');
    });
    test('should default to end of string from far negative index', () {
      expect(loop('ab', -5), 'b');
      expect('ab'.loop(-5), 'b');
    });
    test('should handle in-fragment substring loops away negative', () {
      expect(loop('hello', -4, -2), 'el');
      expect('hello'.loop(-4, -2), 'el');
    });
    test('should handle in-fragment substring loops away positive', () {
      expect(loop('hello', 6, 8), 'el');
      expect('hello'.loop(6, 8), 'el');
    });

    // Backward direction test cases
    test('should traverse backwards', () {
      expect(loop('hello', 3, 0), 'leh');
      expect('hello'.loop(3, 0), 'leh');
    });
    test('should traverse backwards across boundary', () {
      expect(loop('eholl', 2, -3), 'hello');
      expect('eholl'.loop(2, -3), 'hello');
    });
    test('should traverse backwards many loops', () {
      expect(loop('ab', 0, -6), 'bababa');
      expect('ab'.loop(0, -6), 'bababa');
    });

    // Corner cases
    test('should throw on empty', () {
      expect(() => loop('', 6, 8), throwsArgumentError);
      expect(() => ''.loop(6, 8), throwsArgumentError);
    });
  });

  group('center', () {
    test('should return the input if length greater than width', () {
      expect(center('abc', 2, '0'), 'abc');
      expect('abc'.center(2, '0'), 'abc');

      expect(center('abc', 3, '0'), 'abc');
      expect('abc'.center(3, '0'), 'abc');
    });

    test('should pad equal chars on left and right for even padding count', () {
      expect(center('abc', 5, '0'), '0abc0');
      expect('abc'.center(5, '0'), '0abc0');

      expect(center('abc', 9, '0'), '000abc000');
      expect('abc'.center(9, '0'), '000abc000');
    });

    test('should pad extra char on right for odd padding amount', () {
      expect(center('abc', 4, '0'), 'abc0');
      expect('abc'.center(4, '0'), 'abc0');

      expect(center('abc', 8, '0'), '00abc000');
      expect('abc'.center(8, '0'), '00abc000');
    });

    test('should use multi-character fills', () {
      expect(center('abc', 7, '012345'), '01abc45');
      expect('abc'.center(7, '012345'), '01abc45');

      expect(center('abc', 6, '012345'), '0abc45');
      expect('abc'.center(6, '012345'), '0abc45');

      expect(center('abc', 9, '01'), '010abc101');
        expect('abc'.center(9, '01'), '010abc101');
    });

    test('should handle null and empty inputs', () {
      expect(center(null, 4, '012345'), '0145');
      expect(center('', 4, '012345'), '0145');
      expect(''.center(4, '012345'), '0145');

      expect(center(null, 5, '012345'), '01345');
      expect(center('', 5, '012345'), '01345');
      expect(''.center(5, '012345'), '01345');
    });
  });

  group('equalsIgnoreCase', () {
    test('should return true for equal Strings', () {
      expect(equalsIgnoreCase('abc', 'abc'), isTrue);
      expect('abc'.equalsIgnoreCase('abc'), isTrue);
    });

    test('should return true for case-insensitivly equal Strings', () {
      expect(equalsIgnoreCase('abc', 'AbC'), isTrue);
      expect('abc'.equalsIgnoreCase('AbC'), isTrue);
    });

    test('should return true for nulls', () {
      expect(equalsIgnoreCase(null, null), isTrue);
    });

    test('should return false for unequal Strings', () {
      expect(equalsIgnoreCase('abc', 'bcd'), isFalse);
      expect('abc'.equalsIgnoreCase('bcd'), isFalse);
    });

    test('should return false if one is null', () {
      expect(equalsIgnoreCase(null, 'abc'), isFalse);
      expect(equalsIgnoreCase('abc', null), isFalse);
      expect('abc'.equalsIgnoreCase(null), isFalse);
    });
  });

  group('compareIgnoreCase', () {
    test('should return 0 for case-insensitivly equal Strings', () {
      expect(compareIgnoreCase('abc', 'abc'), 0);
      expect('abc'.compareIgnoreCase('abc'), 0);

      expect(compareIgnoreCase('abc', 'AbC'), 0);
      expect('abc'.compareIgnoreCase('AbC'), 0);
    });

    test('should return compare unequal Strings correctly', () {
      expect(compareIgnoreCase('abc', 'abd'), lessThan(0));
      expect('abc'.compareIgnoreCase('abd'), lessThan(0));

      expect(compareIgnoreCase('abc', 'abD'), lessThan(0));
      expect('abc'.compareIgnoreCase('abD'), lessThan(0));

      expect(compareIgnoreCase('abd', 'abc'), greaterThan(0));
      expect('abd'.compareIgnoreCase('abc'), greaterThan(0));

      expect(compareIgnoreCase('abD', 'abc'), greaterThan(0));
      expect('abD'.compareIgnoreCase('abc'), greaterThan(0));
    });
  });
}
