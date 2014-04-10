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

part of quiver.compare;

/**
 * Returns a comparator that compares the result of calling [key] on the
 * items being compared.
 *
 * Example:
 *     ['Bob', 'alice', 'Alice']
 *         ..sort(by((s) => s.toLowerCase())); // alice, Alice, Bob
 */
Comparator by(
    Comparable key(e),
    {Comparator compare : Comparable.compare}) => (a, b) =>
        compare(key(a), key(b));

/**
 * Returns a comparator that breaks ties in [base] with [tieBreaker].
 *
 * Example:
 *     [{'id': 5, 'name': 'foo'}, {'id': 2, 'name': 'foo'}]..sort(compound(
 *            by((m) => m['id']),
 *            base: by((m) => m['name']);
 *
 *            // {'id': 2, 'name': 'foo'}, {'id': 5, 'name': 'foo'}]
 */
Comparator compound(
    Comparator tieBreaker,
    {Comparator base : Comparable.compare}) => (a, b) {

  var v = base(a, b);
  if(v == 0) return tieBreaker(a, b);
  return v;
};

/**
 * Returns a comparator that reverses the order specified by [compare].
 *
 * Example:
 *     [1, 2, 0]..sort(decreasing()); // 2, 1, 0
 */
Comparator reverse(
    {Comparator compare : Comparable.compare}) => (a, b) =>
        compare(b, a);

/**
 * Returns a comparator that orders iterables by comparing corresponding
 * elements pairwise until a nonzero result is found. If the end of one iterable
 * is reached, but not the other, the shorter iterable is considered to be less
 * than the longer one.
 *
 * Example:
 *     [[0, 2], [0, 1]]..sort(lexicographic()); // [[0, 1], [0, 2]]
 */
Comparator<Iterable> lexicographic(
    {Comparator compare : Comparable.compare}) => (Iterable a, Iterable b) {

  var aIterator = a.iterator;
  var bIterator = b.iterator;

  while(true) {
    var aDone = !aIterator.moveNext();
    var bDone = !bIterator.moveNext();
    if(aDone && bDone) return 0;
    if(aDone) return -1;
    if(bDone) return 1;
    var v = compare(aIterator.current, bIterator.current);
    if(v != 0) return v;
  }
};

/**
 * Returns a comparator that orders `null` values before non-null values.
 *
 * Example:
 *     [2, null, 1]..sort(decreasing()); // null, 1, 2
 */
Comparator nullsFirst({Comparator compare : Comparable.compare}) => (a, b) {
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;
  return compare(a, b);
};

/**
 * Returns a comparator that orders `null` values after non-null values.
 *
 * Example:
 *     [2, null, 1]..sort(decreasing()); // 1, 2, null
 */
Comparator nullsLast({Comparator compare : Comparable.compare}) => (a, b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return compare(a, b);
};
