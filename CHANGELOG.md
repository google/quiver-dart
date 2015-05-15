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
