#### 0.28.0 - 2018-01-19

   * BREAKING CHANGE: The signature of `MultiMap`'s `update` stub has changed
     from `V update(K key, C update(C value), {C ifAbsent()})` to
     `C update(K key, C update(C value), {C ifAbsent()})`.

#### 0.27.0 - 2018-01-03

   * BREAKING CHANGE: all classes that implement `Iterable`, `List`, `Map`,
     `Queue`, `Set`, or `Timer` now implement stubs of upcoming Dart 2.0
     methods. Any class that reimplements these classes also needs new method
     implementations. The classes with these breaking changes include:
     `HashBiMap`, `DelegatingIterable`, `DelegatingList`,
     `DelegatingMap`,`DelegatingQueue`, `DelegatingSet`, `LinkedLruHashMap`,
     `TreeSet`, and `AvlTreeSet`.
   * Fix: Use FIFO ordering in `FakeAsync`. PR
     [#265](https://github.com/google/quiver-dart/pull/265)

#### 0.26.2 - 2017-11-16

   * Fix: re-adding the most-recently-used entry to a `LinkedLruHashMap`
     previously introduced a loop in the internal linked list.
   * Fix: when removing an entry in the middle of the `LinkedLruHashMap`, the
     recency list was not correctly re-linked.

#### 0.26.1 - 2017-11-16

   * Fix: when removing the last item, `LinkedLruHashMap` was put into a state
     such that the next cache eviction could cause a null-pointer exception.
     Issue [#385](https://github.com/google/quiver-dart/issues/385).
   * Fix: strong mode fix when calling `merge` on the empty set of iterables.
     PR [#384](https://github.com/google/quiver-dart/pull/384).

#### 0.26.0 - 2017-11-01
   * BREAKING CHANGE: eliminated deprecated `flip`. Replaced by `reverse` in
     0.25.0.
   * BREAKING CHANGE: eliminated deprecated `repeat`. Deprecated in 0.25.0.
     Callers should use `String`'s `*` operator.
   * Deprecated: `reverse` in the `strings` library. No replacement is
     provided.
   * Deprecated: `createTimer`, `createTimerPeriodic` in the `async` library.
     These were originally written to support FakeTimer, which is superseded
     by FakeAsync.
   * New: Added `isLeapYear`, `daysInMonth`, `clampDayOfMonth` APIs in the
     `time` library.
   * Multimap is now backed by a LinkedHashMap rather than HashMap.
   * Multimap: added `contains` to know if an association key/value exists.

#### 0.25.0 - 2017-03-28
   * BREAKING CHANGE: minimum SDK constraint increased to 1.21.0. This allows
     use of async-await and generic function in Quiver.
   * BREAKING CHANGE: eliminated deprecated `FakeTimer`.
   * BREAKING CHANGE: `StreamBuffer<T>` now implements `StreamConsumer<T>` as
     opposed to `StreamConsumer<T|List<T>>`.
   * Deprecated: `FutureGroup`. Use the replacement in `package:async` which
     requires a `close()` call to trigger auto-completion when the count of
     pending tasks drops to 0.
   * Deprecated: `repeat` in the `strings` library. Use the `*` operator on
     the String class.
   * Deprecated: in the strings library, `flip` has been renamed `reverse`.
     `flip` is deprecated and will be removed in the next release.
   * Iterables: `enumerate` is now generic.
   * Collection: added `indexOf`.

#### 0.24.0 - 2016-10-31
   * BREAKING CHANGE: eliminated deprecated `nullToEmpty`, `emptyToNull`.
   * Fix: Strong mode: As of Dart SDK 1.21.0, `Set.difference` takes a
     `Set<Object>` parameter.

#### 0.23.0 - 2016-09-21
   * Strings: `nullToEmpty`, `emptyToNull` deprecated. Removal in 0.24.0.
   * BREAKING CHANGE: eliminated deprecated multimap `toMap`.
   * BREAKING CHANGE: eliminated deprecated `pad*`, `trim*` string functions.

#### 0.22.0 - 2015-04-21
   * BREAKING CHANGE: `streams` and `async` libraries have been [merged](https://github.com/google/quiver-dart/commit/671f1bc75742b4393e203c9520a3bf1e031967dc) into one `async` library
   * BREAKING CHANGE: Pre-1.8.0 SDKs are no longer supported.
   * Quiver is now [strong mode](https://github.com/dart-lang/dev_compiler/blob/master/STRONG_MODE.md) compliant
   * New: `Optional` now implements `Iterable` and its methods are generic (using temporary syntax)
   * New: `isNotEmpty` and `isDigit` in `strings.dart`
   * New: `Multimap.fromIterable`
   * Fix: Change `TreeSearch` from `class` to `enum`.
   * Fix: `fake_async.dart` timers are now active while executing the callback

#### 0.21.4 - 2015-05-15
   * Add stats reporting for fake async tests. You can query the number of
     pending microtasks and timers via `microtaskCount`, `periodicTimerCount`,
     `nonPeriodicTimerCount`.

#### 0.21.3+1 - 2015-05-11
   * Switch from unittest to test.

#### 0.21.3 - 2015-03-03
   * Bugfix: fixed return type on some methods (e.g. `where` of `Iterable`s
     returned by Multimap.

#### 0.21.2 - 2015-03-03
   * Bugfix: fix drifting times in `Metronome`.
   * Add `LruMap` to quiver/collection.
   * Un-deprecate Glob; feedback was that package:glob was not a suitable
     replacement in many cases. Key reasons: dependency on dart:io and
     significantly poorer performance.

#### 0.21.1 - 2015-02-05
   * Add optional start param to `Glob.allMatches()` to match superclass
     method signature.
   * Add optional start param to `Pattern` returned by `matchesAny()` to match
     superclass method signature.
   * Deprecate Glob. Use package:glob. Will be removed in 0.22.0.

#### 0.21.0+3 - 2015-02-04
   * Travis CI integration support added.
   * Document that the deprecated functions `padLeft`, `padRight`, `trimLeft`,
     `trimRight` will be removed in 0.22.0.

#### 0.21.0+2 - 2015-02-04
   * Fix hanging `FakeAsync` unit test.

#### 0.21.0+1 - 2015-02-03
   * Replace `equalsTester` dependency on `unittest` with finer-grained
     dependency on `matcher`.
   * `path` is now a dev dependency.

#### 0.21.0 - 2015-02-02
   * Multimap: `toMap()` is deprecated and replaced with `asMap()`. `toMap()`
     will be removed in v0.22.0.
   * Cleanup method signatures that were inconsistent with the core library.
   * Added `areEqualityGroups` matcher for testing `operator==` and `hashCode`.
   * CONTRIBUTING.md added.

#### 0.20.0 - 2014-12-10
   * Multimap: better `toString()` on returned collections.
   * Multimap: Bugfix: support edits on empty value collections.
   * Multimap: Added missing return statment in `fold`.
   * Added isEmpty() in `strings`.
   * Added max SDK constraint <2.0.0
   * Minor updates to README.md.
   * CHANGELOG.md added

#### 0.19.0+1 - 2014-11-12
   * Corrected version constraint suggestion in README.md.
