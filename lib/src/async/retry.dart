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

part of quiver.async;

/**
 * Defines the type of [Function] that is called by [start] on each
 * catchError. Functions of this type are supplied the caught [err], the
 * failed [retry] count, and the [elapsed] Duration of all attempts so far.
 *
 * An OnErrorFunc returns null if the next attempt (the '[retry] + 1' retry,
 * AKA the '[retry] + 2' attempt) should be made, or an error Object if
 * retrying should cease.
 *
 * [retry] has a value of [INITIAL_TRY] (zero) the first time the
 * OnErrorFunc is invoked, just after the failure of the first attempt
 * (which is not, techically, a "retry", but *the* "try") of the
 * newFuture() call. This zero value is provided so a custom OnErrorFunc
 * can implement different behavior between the failure of the initial
 * attempt (e.g. switch the UI to displaying an error message) and failures
 * of subsequent retries (e.g. update the displayed error message). [retry]
 * will be [FIRST_RETRY] (one) when the OnErrorFunc is next called if the
 * first "re"-try failed, and increment from there for subsequent calls.
 *
 * [elapsed] is the total elapsed time so far, including any time used by
 * the initial failed attempt. [elapsed] is a snapshot captured each
 * time the newFuture() call fails. For consistency, the same "snapshot"
 * value of [elapsed] is passed to both the OnErrorFunc and the
 * [RetryDelayFunc] for a given failed newFuture() call.
 */
typedef Object OnErrorFunc(Object err, int retry, Duration elapsed);

const int INITIAL_TRY = 0;
const int NO_TRIES = INITIAL_TRY - 1;
const int FIRST_RETRY = INITIAL_TRY + 1;

/**
 * Defines the type of [Function] that is called by [start] prior to
 * scheduling a newFuture retry to determine the delay before the retry is
 * attempted. Functions of this type are supplied the upcoming [retry] and
 * the [elapsed] Duration of all attempts so far.
 *
 * A RetryDelayFunc returns a Duration containing the delay to be used for
 * scheduling the upcoming newFuture() retry (the one that is indicated by
 * the [retry] value).
 *
 * The first time the RetryDelayFunc is called, [retry] has a value of
 * [FIRST_RETRY] (one), corresponding to the first upcoming newFuture()
 * retry. "Upcoming" because this is a request for the delay to
 * be used when scheduling that future retry, not the retry (or initial
 * attempt) that just failed.  This first time request is just after the
 * failure of the first newFuture() call that was attempted, and just before
 * the first newFuture() retry will be scheduled. [retry] increments from
 * there for subsequent calls.
 *
 * [elapsed] is the total elapsed time so far, including any time used by
 * the initial failed attempt. [elapsed] is a snapshot captured each
 * time the newFuture() call fails. For consistency, the same "snapshot"
 * value of [elapsed] is passed to both the RetryDelayFunc and the
 * [OnErrorFunc] for a given failed newFuture() call.
 */
typedef Duration RetryDelayFunc(int retry, Duration elapsed);

/**
 * NewFuture is a [Function] type that accepts no arguments and returns
 * a Future. It is the Function type of the newFuture argument supplied
 * when [start] is called.
 */
typedef Future NewFuture();

/**
 * A default [OnErrorFunc] that always returns null. This results in
 * never-ending retries if some newFuture() call does not eventually
 * succeed.
 */
Object retriesInfinite(Object err, int retry, Duration elapsed) => null;

/**
 * A simple [OnErrorFunc] that always returns the supplied error, thus
 * resulting in no retries after the failure of the initial newFuture()
 * call attempt.
 */
Object retriesNone(Object err, int retry, Duration elapsed) => err;

/**
 * Returns an [OnErrorFunc] that returns the supplied error once the
 * count of failed retries equals [max]. When [retry] equals [max], this
 * means that:
 * 1) the initial attempt (the "try" before any retries) has failed
 * 2) [max] retries were executed and all failed, since an OnErrorFunc
 *    is called just after the failure of the [retry] Otherwise, the returned
 * [OnErrorFunc] returns null.
 */
OnErrorFunc makeRetriesMax(int max) {
  return ((Object err, int retry, Duration elapsed) {
    return (retry >= max) ? err : null;
  });
}

/**
 * Returns an [OnErrorFunc] that returns the supplied error once the total
 * [Duration] of all attempts is equal to or exceeds [max]. Otherwise, the
 * returned [OnErrorFunc] returns null.
 */
OnErrorFunc makeRetriesElapsed(Duration max) {
  return ((Object err, int retry, Duration elapsed) {
    return (elapsed >= max) ? err : null;
  });
}

/**
 * Simply combines [makeRetriesMax] and [makeRetriesElapsed], returning
 * an [OnErrorFunc] that itself returns the supplied error if either the
 * [maxRetries] or [maxElapsed] limits are reached. Otherwise, the
 * returned [OnErrorFunc] returns null.
 */
OnErrorFunc makeRetriesLimited(int maxRetries, Duration maxElapsed) {
  OnErrorFunc retriesMax = makeRetriesMax(maxRetries);
  OnErrorFunc retriesElapsed = makeRetriesElapsed(maxElapsed);

  return ((Object err, int retry, Duration elapsed) {
    Object error = retriesMax(err, retry, elapsed);
    if (error != null) { return error; }
    return retriesElapsed(err, retry, elapsed);
  });
}

const Duration NO_DELAY = Duration.ZERO;

/**
 * A trivial [RetryDelayFunc] that indicates there should be no delay
 * before attempting the next newFuture retry. [NO_DELAY] (Duration.ZERO)
 * is always returned.
 */
Duration delayNone(int retry, Duration elapsed) => NO_DELAY;

/**
 * Returns a somewhat trivial [RetryDelayFunc] that simply always returns
 * the supplied [delay].
 */
RetryDelayFunc makeDelayFixed(Duration delay) {
  return ((int retry, Duration elapsed) {
    return delay;
  });
}

math.Random _rnd = new math.Random();

/**
 * A helper function (exposed for writing custom [RetryDelayFunc]) that
 * returns the supplied [delay], adjusted by a random offset in the range
 * of +/- [delay] * [scale], intended for use with the Future.delayed
 * constructor.
 *
 * Negative [delay] Durations and [scale] factors outside of the range
 * (0.0, 1.0) exclusive can return negative Durations, which are basically
 * meaninglesss, but are accepted anyway, since they just result in
 * "no delay" for the Future.delayed constructor.
 */
Duration randomDelay(Duration delay, double scale) {
  Duration offset = delay * scale;
  return delay + ((offset * 2.0 * _rnd.nextDouble()) - offset);
}

const double DEFAULT_SCALE = 0.5;

/**
 * Returns a [RetryDelayFunc] that returns the supplied [delay] adjusted,
 * each time called, by a [randomDelay] using [scale]. If delay is a zero or
 * negative duration, the [delayNone] [RetryDelayFunc] is returned instead.
 *
 * [scale] is truncated to the range (0.0, 1.0) exclusive, to avoid
 * producing negative delays.
 *
 * The principal use of this delay strategy is to avoid surges of
 * simultaneously-retrying clients in the event of a server-side failure.
 */
RetryDelayFunc makeDelayRandom(Duration delay, {double scale: DEFAULT_SCALE}) {
  if (delay <= NO_DELAY) { return delayNone; }
  scale = scale.clamp(double.MIN_POSITIVE, 1.0 - double.MIN_POSITIVE);
  return ((int retry, Duration elapsed) => randomDelay(delay, scale));
}

const Duration NO_CAP = Duration.ZERO;

/**
 * A helper function (exposed for writing custom [RetryDelayFunc]) that
 * returns [delay] capped at an optional [cap], which if null or less than
 * or equal to [NO_CAP] (Duration.ZERO) indicates "no cap" and delay is
 * returned unchanged.
 */
Duration capDelay(Duration delay, Duration cap) {
  if ((cap == null) || (cap <= NO_CAP)) {
    return delay;  // No cap or explicitly NO_CAP specified.
  } else {
    return (delay > cap) ? cap : delay;
  }
}

/**
 * A helper function (exposed for writing custom [RetryDelayFunc]) that
 * returns a doubled [delay], optionally capped via capDelay. Called
 * repeatedly with the previous result, this results in an exponentially
 * increasing delay (up to [cap], which defaults to [NO_CAP]).
 */
Duration backOffDelay(Duration delay, {Duration cap: NO_CAP}) {
  return capDelay(delay * 2.0, cap);
}

/**
 * Returns a [RetryDelayFunc] that returns a [delay] that is exponentially
 * increasing with each subsequent call to that returned [RetryDelayFunc],
 * optionally capped at a [cap] (defaults to [NO_CAP]).
 */
RetryDelayFunc makeDelayBackOff(Duration delay, {Duration cap: NO_CAP}) {
  return ((int retry, Duration elapsed) {
    // Return the existing delay value, possibly capped.
    Duration capped = capDelay(delay, cap);
    // Compute the value to be used on the next iteration, and replace the
    // existing delay with that inside the closure.
    delay = backOffDelay(capped);
    return capped;
  });
}

/**
 * Returns a [RetryDelayFunc] that returns a [delay] that is both
 * exponentially increasing and includes a random adjustment with the
 * specified [scale] (default is +/- 1/2 each subsequent delay) that is
 * also optionally capped at a [cap] (which defaults to [NO_CAP]).
 */
RetryDelayFunc makeDelayBackOffRandom(Duration delay,
    {double scale: DEFAULT_SCALE, Duration cap: NO_CAP}) {
  return ((int retry, Duration elapsed) {
    // Adjust the current delay a random offset.
    Duration random = randomDelay(delay, scale);
    // Insure randomly-adjusted delay does not exceed the specified cap.
    Duration capped = capDelay(random, cap);
    // Compute the value to be used on the next iteration, and replace the
    // existing delay with that inside the closure.
    delay = backOffDelay(capped);
    return capped;
  });
}

/**
 * Accepts a [newFuture] [Function] which returns a [Future], an optional
 * [onError] [OnErrorFunc], an optional [retryDelay] [RetryDelayFunc], and
 * an optional [runTime] [Stopwatch].
 *
 * If supplied, onError is called just after each error that is caught by
 * the .catchError of the Future returned by newFuture (after the initial
 * failed attempt and any subsequent failed retries). Otherwise,
 * [retriesInfinite] is the default.
 *
 * If supplied, retryDelay is called just before each upcoming retry (but
 * not before the initial attempt, which is the "try", not a "retry") to
 * determine the delay that should elapse before that next retry is
 * executed. Otherwise, [delayNone] is the default.
 *
 * The caller can optionally supply a Stopwatch if examining or monitoring
 * the elapsed time of the Future retries outside of onError and retryDelay
 * is desired. If supplied, [stop] and [reset] will be called on it before
 * [start] is called to begin counting the elapsed time.  A Stopwatch
 * supplied by the caller in this way can be observed via its [elapsed]
 * property, but must not otherwise be manipulated or altered (that is, do
 * not call stop, reset, or start on it). If not supplied by the caller, a
 * new Stopwatch is created internally and used.
 *
 * This method returns a Future that can be used to determine if a Future
 * produced by newFuture did (eventually) succeed before the [onError]
 * function prematurely terminated any additional newFuture attempts.
 */
Future start(NewFuture newFuture, {
    OnErrorFunc onError: retriesInfinite,
    RetryDelayFunc retryDelay: delayNone,
    Stopwatch runTime}) {
  // Closures will "capture" these local variables.
  int retries = INITIAL_TRY;
  if (runTime != null) {
    runTime.stop();
    runTime.reset();
  } else {
    runTime = new Stopwatch();
  }
  runTime.start();

  // Wrap the Future result to return the result passed to .then after
  // stopping the runTime Stopwatch.
  thenCompleted(futureResult) {
    runTime.stop();
    return futureResult;
  };

  computation() {
    return newFuture()
      .then(thenCompleted)
      .catchError((e) {
        // Snapshot values so far, for onError and retryDelay consistency.
        int onErrorRetry = retries;
        Duration atOnError = runTime.elapsed;
        Object err = onError(e, onErrorRetry, atOnError);

        if (err != null) {
          runTime.stop();
          return new Future.error(err);
        } else {
          // onError returned null, thus indicating that (at least) one
          // more retry of newFuture() should be scheduled.
          int nextRetry = onErrorRetry + 1;
          retries = nextRetry;
          Duration delay = retryDelay(nextRetry, atOnError);
          return new Future.delayed(delay, computation);
        }
      });
  };

  return computation();
}
