quiver-dart
===========

A set of utility libraries for Dart

## iterables.dart

Functions for transforming Iterables in different ways, similar to Python's
itertools.

These include `count`, `cycle`, `enumerate`, `range`, `zip`, `min`, `max`, and
`extent`.

## pattern.dart

pattern.dart container utilities for work with `Pattern`s and `RegExp`s.

`Glob` implements glob patterns that are commonly used with filesystem paths.

`matchesAny` combines multiple Patterns into one, and allows for exclusions.

`matchesFull` returns true if a Pattern matches an entire String.

## async.dart

Utilities for working with Futures, Streams and async computations.

`FutureGroup` is collection of Futures that signals when all it's child futures
have completed. Allows adding new Futures as long as it hasn't completed yet.
Useful when async tasks can spwn new async tasks and you need to wait for all of
them to complete.

`doWhileAsync` and `reduceAsync` perform async computations on Iterables.
