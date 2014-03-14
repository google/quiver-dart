Quiver
======

Quiver is a set of utility libraries for Dart that makes using many Dart
libraries easier and more convenient, or adds additional functionality.

[![Build Status](https://drone.io/github.com/google/quiver-dart/status.png)](https://drone.io/github.com/google/quiver-dart/latest)

## Documentation

API Docs can be found here: http://google.github.io/quiver-dart/

## Installation

Add Quiver to your project's pubspec.yaml file and run `pub get`.
We recommend the following version constraint:

    dependencies:
      quiver: '>=0.18.0<0.19.0'

# Main Libraries

## [quiver.async][]

Utilities for working with Futures, Streams and async computations.

`FutureGroup` is collection of Futures that signals when all its child futures
have completed. Allows adding new Futures as long as it hasn't completed yet.
Useful when async tasks can spwn new async tasks and you need to wait for all of
them to complete.

`StreamRouter` splits a Stream into mulltiple streams based on a set of
predicates.

`CountdownTimer` is a simple countdown timer that fires events in regular
increments.

`doWhileAsync`, `reduceAsync` and `forEachAsync` perform async computations on
the elements of on Iterables, waiting for the computation to complete before
processing the next element.

`CreateTimer` and `CreateTimerPeriodic` are typedefs that are useful for
passing Timer factories to classes and functions, increasing the testability of
code that depends on Timer.

[quiver.async]: http://google.github.io/quiver-dart/#quiver/quiver-async

## [quiver.cache][]

`Cache` is a semi-persistent, asynchronously accessed, mapping of keys to
values. Caches are similar to Maps, except that the cache implementation might
store values in a remote system, so all operations are asynchronous, and caches
might have eviction policies.

`MapCache` is a Cache implementation backed by a Map.

[quiver.cache]: http://google.github.io/quiver-dart/#quiver/quiver-cache

## [quiver.collection][]

`listsEqual` and `mapsEqual` check collections for equality.

`Multimap` is an associative collection that maps keys to collections of
values.

`BiMap` is a bidirectional map and provides an inverse view, allowing
lookup of key by value.

`TreeSet` is a balanced binary tree that offers a bidirectional iterator,
the ability to iterate from an arbitrary anchor, and 'nearest' search.

[quiver.collection]: http://google.github.io/quiver-dart/#quiver/quiver-collection

## [quiver.core][]

`Optional` is a way to represent optional values without allowing `null`.

`firstNonNull` returns its first non-null argument.

`hashObjects`, `hash2`, `hash3`, and `hash4` generate high-quality hashCodes for
a list of objects, or 2, 3, or 4 arguments respectively.

[quiver.core]: http://google.github.io/quiver-dart/#quiver/quiver-core

## [quiver.io][]

`visitDirectory` is a recursive directory lister that conditionally recurses
into sub-directories based on the result of a handler function.

[quiver.io]: http://google.github.io/quiver-dart/#quiver/quiver-io

## [quiver.iterables][]

`concat`, `count`, `cycle`, `enumerate`, `merge`, `partition`, `range`, and
`zip` create, transform, or combine Iterables in different ways, similar to
Python's itertools.

`min`, `max`, and `extent` retreive the minimum and maximum elements from an
iterable.

[quiver.iterables]: http://google.github.io/quiver-dart/#quiver/quiver-iterables

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

[quiver.mirrors]: http://google.github.io/quiver-dart/#quiver/quiver-mirrors

## [quiver.pattern][]

pattern.dart container utilities for work with `Pattern`s and `RegExp`s.

`Glob` implements glob patterns that are commonly used with filesystem paths.

`matchesAny` combines multiple Patterns into one, and allows for exclusions.

`matchesFull` returns true if a Pattern matches an entire String.

`escapeRegex` escapes special regex characters in a String so that it can be
used as a literal match inside of a RegExp.

[quiver.pattern]: http://google.github.io/quiver-dart/#quiver/quiver-pattern

## [quiver.streams][]

`Stream` versions of [quiver.iterables][] methods.  Currently `enumerate` and 
`concat` are supported.

[quiver.streams]: http://google.github.io/quiver-dart/#quiver/quiver-streams

## [quiver.strings][]

`isBlank` checks if a string is `null`, empty or made of whitespace characters.

`equalsIgnoreCase` checks if two strings are equal, ignoring case.

`compareIgnoreCase` compares two strings, ignoring case.

`flip` flips the order of characters in a string.

`nullToEmpty` turns `null` to empty string, and returns non-empty strings
unchanged.

`emptyToNull` turns empty string to `null`, and returns non-empty strings
unchanged.

`repeat` concatenates a string to itself a given number of times, for example:

`repeat('la ', 3) => 'la la la '`

It can also repeat in reverse, for example:

`repeat(' og', -3) => 'go go go '`

`loop` allows you to loop through characters in a string starting and ending at
arbitrary indices. Out of bounds indices allow you to wrap around the string,
supporting a number of use-cases, including:

  * Rotating: `loop('lohel', -3, 2) => 'hello'`
  * Repeating, like `repeat`, but with better character-level control, e.g.:
`loop('la ', 0, 8) => 'la la la'  // no tailing space`
  * Tailing: `loop('/path/to/some/file.txt', -3) => 'txt'`
  * Reversing: `loop('top', 3, 0) => 'pot'`

`padLeft`, `padRight`, and `center` pad strings to a given width.

`trimLeft` and `trimRight` remove leading and trailing whitespace.

[quiver.strings]: http://google.github.io/quiver-dart/#quiver/quiver-strings

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

[quiver.time]: http://google.github.io/quiver-dart/#quiver/quiver-time

# Testing Libraries

The Quiver testing libraries are intended to be used in testing code, not
production code. It currently consists of fake implementations of some Quiver
interfaces.

## [quiver.testing.async][]

`FakeTimer` is a Timer that captures its duration and callback for use in tests.

[quiver.testing.async]: http://google.github.io/quiver-dart/#quiver/quiver-testing.async

## [quiver.testing.time][]

`FakeStopwatch` is a Stopwatch that uses a provided `now()` function to get the
current time.

[quiver.testing.time]: http://google.github.io/quiver-dart/#quiver/quiver-testing.time
