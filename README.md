Quiver
======

Quiver is a set of utility libraries for Dart that makes using many Dart
libraries easier and more convenient, or adds additional functionality.

[![Build Status](https://travis-ci.org/google/quiver-dart.svg?branch=master)](https://travis-ci.org/google/quiver-dart)
[![Coverage Status](https://img.shields.io/coveralls/google/quiver-dart.svg)](https://coveralls.io/r/google/quiver-dart)

## Documentation

[API Docs](http://www.dartdocs.org/documentation/quiver/latest) are available.

## Installation

Add Quiver to your project's pubspec.yaml file and run `pub get`.
We recommend the following version constraint:

    dependencies:
      quiver: '>=0.25.0 <0.26.0'

# Main Libraries

## [quiver.async][]

Utilities for working with Futures, Streams and async computations.

`collect` collects the completion events of an `Iterable` of `Future`s into a
`Stream`.

`enumerate` and `concat` represent `Stream` versions of the same-named
[quiver.iterables][] methods.

`doWhileAsync`, `reduceAsync` and `forEachAsync` perform async computations on
the elements of on Iterables, waiting for the computation to complete before
processing the next element.

`StreamBuffer` allows for the orderly reading of elements from a stream, such
as a socket.

`FutureGroup` is collection of Futures that signals when all its child futures
have completed. Allows adding new Futures as long as it hasn't completed yet.
Useful when async tasks can spwn new async tasks and you need to wait for all of
them to complete.

`FutureStream` turns a `Future<Stream>` into a `Stream` which emits the same
events as the stream returned from the future.

`StreamRouter` splits a Stream into mulltiple streams based on a set of
predicates.

`CountdownTimer` is a simple countdown timer that fires events in regular
increments.

`CreateTimer` and `CreateTimerPeriodic` are typedefs that are useful for
passing Timer factories to classes and functions, increasing the testability of
code that depends on Timer.

`Metronome` is a self-correcting alternative to `Timer.periodic`. It provides
a simple, tracking periodic stream of `DateTime` events with optional anchor
time.

[quiver.async]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-async

## [quiver.cache][]

`Cache` is a semi-persistent, asynchronously accessed, mapping of keys to
values. Caches are similar to Maps, except that the cache implementation might
store values in a remote system, so all operations are asynchronous, and caches
might have eviction policies.

`MapCache` is a Cache implementation backed by a Map.

[quiver.cache]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-cache

## [quiver.check][]

`checkArgument` throws `ArgumentError` if the specifed argument check expression
is false.

`checkListIndex` throws `RangeError` if the specified index is out of bounds.

`checkNotNull` throws `ArgumentError` if the specified argument is null.

`checkState` throws `StateError` if the specifed state check expression is
false.

[quiver.check]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-check

## [quiver.collection][]

`listsEqual`, `mapsEqual` and `setsEqual` check collections for equality.

`LruMap` is a map that removes the least recently used item when a threshold
length is exceeded.

`Multimap` is an associative collection that maps keys to collections of
values.

`BiMap` is a bidirectional map and provides an inverse view, allowing
lookup of key by value.

`TreeSet` is a balanced binary tree that offers a bidirectional iterator,
the ability to iterate from an arbitrary anchor, and 'nearest' search.

[quiver.collection]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-collection

## [quiver.core][]

`Optional` is a way to represent optional values without allowing `null`.

`firstNonNull` returns its first non-null argument.

`hashObjects`, `hash2`, `hash3`, and `hash4` generate high-quality hashCodes for
a list of objects, or 2, 3, or 4 arguments respectively.

[quiver.core]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-core

## [quiver.io][]

`visitDirectory` is a recursive directory lister that conditionally recurses
into sub-directories based on the result of a handler function.

[quiver.io]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-io

## [quiver.iterables][]

`concat`, `count`, `cycle`, `enumerate`, `merge`, `partition`, `range`, and
`zip` create, transform, or combine Iterables in different ways, similar to
Python's itertools.

`min`, `max`, and `extent` retreive the minimum and maximum elements from an
iterable.

`GeneratingIterable` is an easy way to create lazy iterables that produce
elements by calling a function. A common use-case is to traverse properties in
an object graph, like the parent relationship in a tree.

`InfiniteIterable` is a base class for Iterables that throws on operations that
require a finite length.

[quiver.iterables]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-iterables

## [quiver.mirrors][]

`getTypeName` returns the name of a Type instance.

`implements` and `classImplements` determine if an instance or ClassMirror,
respectively, implement the interface represented by a Type instance. They
implement the behavior of `is` for mirrors, except for generics.

`getMemberMirror` searches though a ClassMirror and its class hierarchy for
a member. This makes up for the fact that `ClassMirror.members` doesn't
contain members from interfaces or superclasses.

`Method` wraps an InstanceMirror and Symbol to create a callable that invokes
a method on the instance. It in effect closurizes a method reflectively.

[quiver.mirrors]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-mirrors

## [quiver.pattern][]

pattern.dart container utilities for work with `Pattern`s and `RegExp`s.

`Glob` implements glob patterns that are commonly used with filesystem paths.

`matchesAny` combines multiple Patterns into one, and allows for exclusions.

`matchesFull` returns true if a Pattern matches an entire String.

`escapeRegex` escapes special regex characters in a String so that it can be
used as a literal match inside of a RegExp.

[quiver.pattern]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-pattern

## [quiver.strings][]

`isBlank` checks if a string is `null`, empty or made of whitespace characters.

`isEmpty` checks if a string is `null` or empty.

`equalsIgnoreCase` checks if two strings are equal, ignoring case.

`compareIgnoreCase` compares two strings, ignoring case.

`flip` flips the order of characters in a string.

`nullToEmpty` turns `null` to empty string, and returns non-empty strings
unchanged.

`emptyToNull` turns empty string to `null`, and returns non-empty strings
unchanged.

`repeat` concatenates a string to itself a given number of times.

`loop` allows you to loop through characters in a string starting and ending at
arbitrary indices. Out of bounds indices allow you to wrap around the string,
supporting a number of use-cases, including:

  * Rotating: `loop('lohel', -3, 2) => 'hello'`
  * Repeating, like `repeat`, but with better character-level control, e.g.:
`loop('la ', 0, 8) => 'la la la'  // no tailing space`
  * Tailing: `loop('/path/to/some/file.txt', -3) => 'txt'`
  * Reversing: `loop('top', 3, 0) => 'pot'`

 `split` splits a string on a given pattern, removing whitespace and empty splits

[quiver.strings]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-strings

## [quiver.time][]

`Clock` provides points in time relative to the current point in time, for
example: now, 2 days ago, 4 weeks from now, etc. For tesability, use Clock
rather than other ways of accessing time, like `new DateTime()`, so that you
can use a fake time function in your tests to control time.

`Now` is a typedef for functions that return the current time in microseconds,
since Clock deals in DateTime which only have millisecond accuracy.

`aMicrosecond`, `aMillisecond`, `aSecond`, `aMinute`, `anHour`, `aDay`, and
`aWeek` are unit duration constants to allow writing for example:

* `aDay` vs. `const Duration(days: 1)`
* `aSecond * 30` vs. `const Duration(seconds: 30)`

[quiver.time]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-time

# Testing Libraries

The Quiver testing libraries are intended to be used in testing code, not
production code. It currently consists of fake implementations of some Quiver
interfaces.

## [quiver.testing.async][]

`FakeAsync` enables testing of units which depend upon timers and microtasks.
It supports fake advancements of time and the microtask queue, which cause fake
timers and microtasks to be processed. A `Clock` is provided from which to read
the current fake time.  Faking synchronous or blocking time advancement is also
supported.

[quiver.testing.async]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-testing-async

## [quiver.testing.equality][]

`areEqualityGroups` is a matcher that supports testing `operator==` and
`hashCode` implementations.

[quiver.testing.equality]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-testing-equality

## [quiver.testing.runtime][]

`assertCheckedMode` asserts the current runtime has checked mode enabled.

[quiver.testing.runtime]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-testing-runtime

## [quiver.testing.time][]

`FakeStopwatch` is a Stopwatch that uses a provided `now()` function to get the
current time.

[quiver.testing.time]: http://www.dartdocs.org/documentation/quiver/latest#quiver/quiver-testing-time
