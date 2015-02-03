#### 0.21.0+1
   * Replace `equalsTester` dependency on `unittest` with finer-grained
     dependency on `matcher`.
   * `path` is now a dev dependency.

#### 0.21.0
   * Multimap: `toMap()` is deprecated and replaced with `asMap()`. `toMap()`
     will be removed in v0.22.0.
   * Cleanup method signatures that were inconsistent with the core library.
   * Added `areEqualityGroups` matcher for testing `operator==` and `hashCode`.
   * CONTRIBUTING.md added.

#### 0.20.0
   * Multimap: better `toString()` on returned collections.
   * Multimap: Bugfix: support edits on empty value collections.
   * Multimap: Added missing return statment in `fold`.
   * Added isEmpty() in `strings`.
   * Added max SDK constraint <2.0.0
   * Minor updates to README.md.
   * CHANGELOG.md added

#### 0.19.0+1
   * Corrected version constraint suggestion in README.md.
