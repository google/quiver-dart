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

  group('padLeft', () {
    test('should return the input if length greater than width', () {
      expect(padLeft('abc', 2, '0'), 'abc');
      expect(padLeft('abc', 3, '0'), 'abc');
    });

    test('should pad on the left if length less than width', () {
      expect(padLeft('abc', 4, '0'), '0abc');
      expect(padLeft('abc', 6, '0'), '000abc');
    });

    test('should use multi-character fills', () {
      expect(padLeft('abc', 4, '012345'), '0abc');
      expect(padLeft('abc', 6, '012345'), '012abc');
      expect(padLeft('abc', 8, '012'), '01201abc');
    });

    test('should handle null and empty inputs', () {
      expect(padLeft(null, 4, '012345'), '0123');
      expect(padLeft('', 4, '012345'), '0123');
      expect(padLeft(null, 4, '012'), '0120');
      expect(padLeft('', 4, '012'), '0120');
    });

  });

  group('padRight', () {
    test('should return the input if length greater than width', () {
      expect(padRight('abc', 2, '0'), 'abc');
      expect(padRight('abc', 3, '0'), 'abc');
    });

    test('should pad on the right if length less than width', () {
      expect(padRight('abc', 4, '0'), 'abc0');
      expect(padRight('abc', 6, '0'), 'abc000');
    });

    test('should use multi-character fills', () {
      expect(padRight('abc', 4, '012345'), 'abc5');
      expect(padRight('abc', 6, '012345'), 'abc345');
      expect(padRight('abc', 8, '012'), 'abc12012');
    });

    test('should handle null and empty inputs', () {
      expect(padRight(null, 4, '012345'), '2345');
      expect(padRight('', 4, '012345'), '2345');
      expect(padRight(null, 4, '012'), '2012');
      expect(padRight('', 4, '012'), '2012');
    });

  });

  group('trimLeft', () {

    test('should trim whitespace from the left', () {
      expect(trimLeft(''), '');
      expect(trimLeft(' '), '');
      expect(trimLeft('  abc  '), 'abc  ');
      expect(trimLeft('  abc def  '), 'abc def  ');
      expect(trimLeft('\t\vabc  '), 'abc  ');
      // these are some of the whitespace chars not defined for RexExps
      expect(trimLeft('\u000Aabc  '), 'abc  ');
      expect(trimLeft('\u000Dabc  '), 'abc  ');
      expect(trimLeft('\u0085abc  '), 'abc  ');
      expect(trimLeft('\u1680abc  '), 'abc  ');
    });

    test('should throw on null', () {
      expect(() => trimLeft(null), throws);
    });

  });


  group('trimRight', () {

    test('should trim whitespace from the right', () {
      expect(trimRight(''), '');
      expect(trimRight(' '), '');
      expect(trimRight('  abc  '), '  abc');
      expect(trimRight('  abc def  '), '  abc def');
      expect(trimRight('  abc\t\v'), '  abc');
      // these are some of the whitespace chars not defined for RexExps
      expect(trimRight('  abc\u000A'), '  abc');
      expect(trimRight('  abc\u000D'), '  abc');
      expect(trimRight('  abc\u0085'), '  abc');
      expect(trimRight('  abc\u1680'), '  abc');
    });

    test('should throw on null', () {
      expect(() => trimRight(null), throws);
    });

  });


  group('center', () {
    test('should return the input if length greater than width', () {
      expect(center('abc', 2, '0'), 'abc');
      expect(center('abc', 3, '0'), 'abc');
    });

    test('should pad equal chars on left and right for even padding count', () {
      expect(center('abc', 5, '0'), '0abc0');
      expect(center('abc', 9, '0'), '000abc000');
    });

    test('should pad extra char on right for odd padding amount', () {
      expect(center('abc', 4, '0'), 'abc0');
      expect(center('abc', 8, '0'), '00abc000');
    });

    test('should use multi-character fills', () {
      expect(center('abc', 7, '012345'), '01abc45');
      expect(center('abc', 6, '012345'), '0abc45');
      expect(center('abc', 9, '01'), '010abc101');
    });

    test('should handle null and empty inputs', () {
      expect(center(null, 4, '012345'), '0145');
      expect(center('', 4, '012345'), '0145');
      expect(center(null, 5, '012345'), '01345');
      expect(center('', 5, '012345'), '01345');
    });

  });

  group('equalsIgnoreCase', () {
    test('should return true for equal Strings', () {
      expect(equalsIgnoreCase('abc', 'abc'), isTrue);
    });

    test('should return true for case-insensitivly equal Strings', () {
      expect(equalsIgnoreCase('abc', 'AbC'), isTrue);
    });

    test('should return true for nulls', () {
      expect(equalsIgnoreCase(null, null), isTrue);
    });

    test('should return false for unequal Strings', () {
      expect(equalsIgnoreCase('abc', 'bcd'), isFalse);
    });

    test('should return false if one is null', () {
      expect(equalsIgnoreCase('abc', null), isFalse);
      expect(equalsIgnoreCase(null, 'abc'), isFalse);
    });

  });

  group('compareIgnoreCase', () {
    test('should return 0 for case-insensitivly equal Strings', () {
      expect(compareIgnoreCase('abc', 'abc'), 0);
      expect(compareIgnoreCase('abc', 'AbC'), 0);
    });

    test('should return compare unequal Strings correctly', () {
      expect(compareIgnoreCase('abc', 'abd'), lessThan(0));
      expect(compareIgnoreCase('abc', 'abD'), lessThan(0));
      expect(compareIgnoreCase('abd', 'abc'), greaterThan(0));
      expect(compareIgnoreCase('abD', 'abc'), greaterThan(0));
    });

  });
}
