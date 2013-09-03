quiver-dart
===========

A set of utility libraries for Dart

## async.dart

Utilities for working with Futures, Streams and async computations.

`FutureGroup` is collection of Futures that signals when all its child futures
have completed. Allows adding new Futures as long as it hasn't completed yet.
Useful when async tasks can spwn new async tasks and you need to wait for all of
them to complete.

`StreamRouter` splits a Stream into mulltiple streams based on a set of
predicates.

`CountdownTimer` is a simple countdown timer that fires events in configurable
increments.

`doWhileAsync` and `reduceAsync` perform async computations on the elements of
on Iterables, waiting for the computation to complete before processing the
next element.

## collection.dart

`Multimap` is an associative collection that maps keys to collections of
values.

## io.dart

`visitDirectory` is a recursive directory lister that conditionally recurses
into sub-directories based on the result of a handler function.

## iterables.dart

`count`, `cycle`, `enumerate`, `merge`, `range`, and  `zip` create, transform,
or combine Iterables in different ways, similar to Python's itertools.

`min`, `max`, and `extent` retreive the minimum and maximum elements from an
iterable.

## mirrors.dart

`getTypeName` returns the name of a Type instance.

`implements` and `classImplements` determine if an instance or ClassMirror,
respectively, implement the interface represented by a Type instance. They
implement the behavior of `is` for mirrors, except for generics.

`getMemberMirror` searches though a ClassMirror and its class hierarchy for
a member. This makes up for the fact that `ClassMirror.members` doesn't
contain members from interfaces or superclasses.

`Method` wraps an InstanceMirror and Symbol to create a callable that invokes
a method on the instance. It in effect closurizes a method reflectively.

## pattern.dart

pattern.dart container utilities for work with `Pattern`s and `RegExp`s.

`Glob` implements glob patterns that are commonly used with filesystem paths.

`matchesAny` combines multiple Patterns into one, and allows for exclusions.

`matchesFull` returns true if a Pattern matches an entire String.

`escapeRegex` escapes special regex characters in a String so that it can be
used as a literal match inside of a RegExp.

## time.dart

`Clock` provides points in time relative to the current point in time, for
example: now, 2 days ago, 4 weeks from now, etc. For tesability, use Clock
rather than other ways of accessing time, like `new DateTime()`, so that you
can use a fake time function in your tests to control time.

## strings.dart

`isBlank` checks if a string is `null`, empty or made of whitespace characters.

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

### Rotating
`loop('lohel', -3, 2) => 'hello'`

### Repeating
Like `repeat`, but with better character-level control, e.g.:
`loop('la ', 0, 8) => 'la la la'  // no tailing space`

### Tailing
`loop('/path/to/some/file.txt', -3) => 'txt'`

### Reversing
`loop('top', 3, 0) => 'pot'`

