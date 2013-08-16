quiver-dart
===========

A set of utility libraries for Dart

## iterables.dart

The iterables library contains functions for transforming Iterables in different
ways, similar to Python's itertools. These include `count`, `cycle`,
`enumerate`, `range`, and `zip`.

## pattern.dart

pattern.dart container utilities for work with `Pattern`s and `RegExp`s.

`Glob` implements glob patterns that are commonly used with filesystem paths.

`matchesAny` combines multiple Patterns into one, and allows for exclusions.

`matchesFull` returns true if a Pattern matches an entire String.