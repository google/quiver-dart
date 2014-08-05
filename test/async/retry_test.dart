// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library quiver.async.retry_test;

import 'dart:async';
import 'dart:math' as math;

import 'package:quiver/async.dart' as retry;
import 'package:unittest/unittest.dart';

main() {
  const int maxI = 25;  // This value is arbitrary.

  group('start() retries', () {
    const int rMax = maxI ~/ 2;  // Anything in (1, maxI) exclusive.
    Duration zEl = new Duration();  // Zero elapsed time.

    test('none', () {
      int nI = 0;
      nFuture() {
        if (nI < maxI) { nI += 1; throw nI; }
        return nI;
      };
      nNewFuture() => new Future(nFuture);

      // With retriesNone, do not retry at all.
      return retry.start(nNewFuture, onError: retry.retriesNone)
        .then((v) {
          fail(".then() should not be executed for this test: $v");
        })
        .catchError((e) {
          // No retries if retriesNone.
          expect(nI, 1);  // Only the initial, failed attempt.
          expect(e, 1);  // nFuture threw the value of nI after one attempt.
        });
    });

    test('infinite', () {
      int iI = 0;
      iFuture() {
        if (iI < maxI) { iI += 1; throw iI; }
        return iI;
      };
      iNewFuture() => new Future(iFuture);

      // With default retriesInfinite, retry until no error thrown.
      return retry.start(iNewFuture)
        .then((v) {
          // iFuture is coded to eventually succeed after maxI attempts, when
          // the default retriesInfinite is the onError function.
          expect(v, maxI);
          expect(iI, maxI);
        });
    });

    test('max count', () {
      int mI = 0;
      mFuture() {
        if (mI < maxI) { mI += 1; throw mI; }
        return mI;
      };
      mNewFuture() => new Future(mFuture);

      // With some RetriesMax, retry a limited number of multiple times.
      return retry.start(mNewFuture, onError: retry.makeRetriesMax(rMax))
        .then((v) {
          fail(".then() should not be executed for this test: $v");
        })
        .catchError((e) {
          expect(mI, rMax + 1);
          expect(e, rMax + 1);  // mFuture threw last attempted value of mI.
        });
    });

    test('max elapsed', () {
      int eI = 0;
      eFuture() {
        if (eI < maxI) { eI += 1; throw eI; }
        return eI;
      };
      eNewFuture() => new Future(eFuture);

      // With a zero-time RetriesElapsed, no retries after the first attempt.
      Stopwatch eRT = new Stopwatch();
      return retry.start(eNewFuture,
          onError: retry.makeRetriesElapsed(zEl), runTime: eRT)
        .then((v) {
          fail(".then() should not be executed for this test: $v");
        })
        .catchError((e) {
          // No retries zero RetriesElapsed.
          expect(eI, 1);  // Only the initial, failed attempt.
          expect(e, 1);  // eFuture threw the value of eI after one attempt.
          // Some non-zero time will still have elapsed, even with zero limit.
          expect(eRT.elapsed, greaterThan(zEl));
        });
    });

    test('limited zero elapsed', () {
      int lzI = 0;
      lzFuture() {
        if (lzI < maxI) { lzI += 1; throw lzI; }
        return lzI;
      };
      lzNewFuture() => new Future(lzFuture);

      // Zero-time limit ends before rMax retries.
      Stopwatch lzRT = new Stopwatch();
      return retry.start(lzNewFuture, onError: retry.makeRetriesLimited(
          rMax, zEl), runTime: lzRT)
        .then((v) {
          fail(".then() should not be executed for this test: $v");
        })
        .catchError((e) {
          // No retries zero RetriesElapsed.
          expect(lzI, 1);  // Only the initial, failed attempt.
          expect(e, 1);  // lzFuture threw the value of lzI after one attempt.
          // Some non-zero time will still have elapsed, even with zero limit.
          expect(lzRT.elapsed, greaterThan(zEl));
        });
    });

    test('limited long elapsed', () {
      int lrI = 0;
      lrFuture() {
        if (lrI < maxI) { lrI += 1; throw lrI; }
        return lrI;
      };
      lrNewFuture() => new Future(lrFuture);

      // rMax retries complete rather quickly.
      Duration min5 = new Duration(minutes: 5);
      Stopwatch lrRT = new Stopwatch();
      return retry.start(lrNewFuture,
          onError: retry.makeRetriesLimited(rMax, min5), runTime: lrRT)
        .then((v) {
          fail(".then() should not be executed for this test: $v");
        })
        .catchError((e) {
          expect(lrI, rMax + 1);
          expect(e, rMax + 1);  // mFuture threw last attempted value of mI.
          // Some non-zero time will still have elapsed, even with zero limit.
          expect(lrRT.elapsed, greaterThan(zEl));
        });
    });

    test('custom onError', () {
      int oeI = 0;
      const oeErrors = const ["fee", "phi", "faux", "fum"];
      String oeLast = oeErrors[oeErrors.length - 1];
      Duration oeElMax = new Duration(milliseconds: 50);

      // Simple newFuture Function that always throws a String error.
      oeFuture() {
        int oeIdx = oeI % oeErrors.length;
        oeI += 1;
        throw oeErrors[oeIdx];  // Throw a String rather than int.
      };

      oeNewFuture() => new Future(oeFuture);

      // Completely made-up OnErrorFunc used to illustrate that a user-supplied
      // OnErrorFunc can consume the error, retry count, and elapsed time
      // any way it likes.
      Object oeOnError(Object e, int rt, Duration el) {
        if (e is! String)  return e;  // String is always expected, so fail.

        String state = e as String;

        if (state != oeLast) {
          return null;  // Keep retrying.
        } else {
          if (el >= oeElMax) {
            return e;  // Waited long enough, so exit with the "fum" error.
          } else {
            return null;  // Keep retrying.
          }
        }
      };

      Stopwatch oeRT = new Stopwatch();
      return retry.start(oeNewFuture, onError: oeOnError, runTime: oeRT)
        .then((state) {
          fail(".then() should not be executed for this test: $state");
        })
        .catchError((e) {
          expect((e as String), oeLast);
          expect((e is String), true);
          expect(oeI, greaterThanOrEqualTo(oeErrors.length));
          expect(oeRT.elapsed, greaterThan(oeElMax));
        });
    });
  });

  group('start() delays', () {
    Duration us1 = new Duration(microseconds: 1);
    Duration us500 = new Duration(microseconds: 500);
    Duration ms1 = new Duration(milliseconds: 1);
    Duration ms1p5 = new Duration(microseconds: 1500);
    Duration ms2p5 = ms1 * 2.5;

    test('fixed', () {
      int fdI = 0;
      fdFuture() {
        if (fdI < maxI) { fdI += 1; throw fdI; }
        return fdI;
      };
      fdNewFuture() => new Future(fdFuture);

      Stopwatch fdRT = new Stopwatch();
      return retry.start(fdNewFuture, retryDelay: retry.makeDelayFixed(ms1),
                  runTime: fdRT)
        .then((v) {
          // fdFuture is coded to eventually succeed after maxI attempts, when
          // the default retriesInfinite is the onError function.
          expect(v, maxI);
          expect(fdI, maxI);
          // Multiple attempts should at least exceed the fixed retry delay
          // times the expected number of retries.
          expect(fdRT.elapsed, greaterThan(ms1 * maxI));
        });
    });

    test('random', () {
      int rdI = 0;
      rdFuture() {
        if (rdI < maxI) { rdI += 1; throw rdI; }
        return rdI;
      };
      rdNewFuture() => new Future(rdFuture);

      Duration totalDelay = new Duration();
      retry.RetryDelayFunc p5to1p5ms = retry.makeDelayRandom(ms1, scale: 0.5);

      // Wrap the stock RetryDelayFunc returned by makeDelayRandom in order
      // to test values produced by the generated function.
      Duration rdDelay(int retry, Duration elapsed) {
        Duration delay = p5to1p5ms(retry, elapsed);
        expect(delay, greaterThanOrEqualTo(us500));
        expect(delay, lessThanOrEqualTo(ms1p5));
        if (elapsed < totalDelay) {
          // Test environment is *not* delaying for the full requested
          // Future.delayed value for some reason. Current elapsed time
          // should *always* exceed the total of the delays requested so far.
          totalDelay = elapsed;
        }
        totalDelay = totalDelay + delay;
        return delay;
      };

      Stopwatch rdRT = new Stopwatch();
      return retry.start(rdNewFuture, retryDelay: rdDelay, runTime: rdRT)
        .then((v) {
          // rdFuture is coded to eventually succeed after maxI attempts, when
          // the default retriesInfinite is the onError function.
          expect(v, maxI);
          expect(rdI, maxI);
          // Multiple attempts should at least exceed the total random delay
          // for all retries.
          expect(rdRT.elapsed, greaterThan(totalDelay));
        });
    });

    test('backoff with cap', () {
      int bkI = 0;
      bkFuture() {
        if (bkI < maxI) { bkI += 1; throw bkI; }
        return bkI;
      };
      bkNewFuture() => new Future(bkFuture);

      retry.RetryDelayFunc backOffMax5ms = retry.makeDelayBackOff(
          us500, cap: ms2p5);
      Duration bkLast = us500;

      // Wrap the stock RetryDelayFunc returned by makeDelayBackOff in order
      // to test values produced by the generated function.
      Duration bkDelay(int retry, Duration elapsed) {
        Duration delay = backOffMax5ms(retry, elapsed);
        expect(delay, lessThanOrEqualTo(ms2p5));
        expect(delay, bkLast);
        bkLast = delay * 2.0;
        bkLast = (bkLast > ms2p5) ? ms2p5 : bkLast;
        return delay;
      };

      Stopwatch bkRT = new Stopwatch();
      return retry.start(bkNewFuture, retryDelay: bkDelay, runTime: bkRT)
        .then((v) {
          // bkFuture is coded to eventually succeed after maxI attempts, when
          // the default retriesInfinite is the onError function.
          expect(v, maxI);
          expect(bkI, maxI);
          // Multiple attempts should at least exceed the initial retry delay
          // times the expected number of retries.
          expect(bkRT.elapsed, greaterThan(us500 * maxI));
          // At least one delay should have exceeded the cap, so total
          // elapsed time should definitely exceed that value (and then some).
          expect(bkRT.elapsed, greaterThan(ms2p5));
        });
    });

    test('backoff no cap', () {
      // Smaller number of failures before success, since backoff is uncapped
      // and growing exponentially. Otherwise, test duration is too long.
      const int bnMaxI = 10;
      int bnI = 0;
      bnFuture() {
        if (bnI < bnMaxI) { bnI += 1; throw bnI; }
        return bnI;
      };
      bnNewFuture() => new Future(bnFuture);

      Duration bnFirst = us1;
      Duration bnLast = bnFirst;
      Duration bnTotal = Duration.ZERO;
      retry.RetryDelayFunc backOffMax5ms = retry.makeDelayBackOff(bnFirst);

      // Wrap the stock RetryDelayFunc returned by makeDelayBackOff in order
      // to test values produced by the generated function.
      Duration bnDelay(int retry, Duration elapsed) {
        Duration delay = backOffMax5ms(retry, elapsed);
        expect(delay, bnLast);
        bnTotal = bnTotal + delay;
        bnLast = delay * 2.0;
        return delay;
      };

      Stopwatch bnRT = new Stopwatch();
      return retry.start(bnNewFuture, retryDelay: bnDelay, runTime: bnRT)
        .then((v) {
          // bnFuture is coded to eventually succeed after bnMaxI attempts,
          // when the default retriesInfinite is the onError function.
          expect(v, bnMaxI);
          expect(bnI, bnMaxI);
          // The final delay, not capped, should be the first delay times
          // 2 to the number of interations power.
          double lastScale = math.pow(2.0, bnMaxI);
          expect(bnLast, bnFirst * lastScale);
          // Expect total elapsed time to exceed (due to overhead) the sum of
          // all (exponentially-increasing) delays.
          expect(bnRT.elapsed, greaterThan(bnTotal));
        });
    });

    test('backoff random', () {
      int brI = 0;
      brFuture() {
        if (brI < maxI) { brI += 1; throw brI; }
        return brI;
      };
      brNewFuture() => new Future(brFuture);

      retry.RetryDelayFunc backOffMax5ms = retry.makeDelayBackOffRandom(
          us500, cap: ms2p5);
      Duration brLast = us500;

      // Wrap the stock RetryDelayFunc returned by makeDelayBackOffRandom in
      // order to test values produced by the generated function.
      Duration brDelay(int retry, Duration elapsed) {
        Duration delay = backOffMax5ms(retry, elapsed);
        expect(delay, lessThanOrEqualTo(ms2p5));
        expect(delay.inMicroseconds,
               inInclusiveRange(brLast.inMicroseconds * 0.5,
                                brLast.inMicroseconds * 1.5));
        brLast = delay * 2.0;
        brLast = (brLast > ms2p5) ? ms2p5 : brLast;
        return delay;
      };

      Stopwatch brRT = new Stopwatch();
      return retry.start(brNewFuture, retryDelay: brDelay, runTime: brRT)
        .then((v) {
          // brFuture is coded to eventually succeed after maxI attempts, when
          // the default retriesInfinite is the onError function.
          expect(v, maxI);
          expect(brI, maxI);
          // Multiple attempts should at least exceed the initial retry delay
          // times the expected number of retries.
          expect(brRT.elapsed, greaterThan(us500 * maxI));
          // At least one delay should have exceeded the cap, so total
          // elapsed time should definitely exceed that value (and then some).
          expect(brRT.elapsed, greaterThan(ms2p5));
        });
    });

    test('custom', () {
      int dcI = 0;
      dcFuture() {
        if (dcI < maxI) { dcI += 1; throw dcI; }
        return dcI;
      };
      dcNewFuture() => new Future(dcFuture);

      int cappedRetry = 0;
      const int msCapped = 100;
      Duration capAfter = const Duration(milliseconds: msCapped);

      // Custom RetryDelayFunc that returns a delay that is a multiple of
      // the [retry] parameter, but stops increasing after a certain
      // [elapsed] time.
      Duration dcDelay(int retry, Duration elapsed) {
        // Keep increasing retry multiple so long as maximum elapsed time
        // has not been reached.
        if (elapsed < capAfter) {
          cappedRetry = retry;
        }

        int next = retry + 1;
        Duration delay = ms1 * cappedRetry;
        return delay;
      };

      Stopwatch dcRT = new Stopwatch();
      return retry.start(dcNewFuture, retryDelay: dcDelay, runTime: dcRT)
        .then((v) {
          // dcFuture is coded to eventually succeed after maxI attempts, when
          // the default retriesInfinite is the onError function.
          expect(v, maxI);
          expect(dcI, maxI);
          // Multiple attempts should at least exceed the initial retry delay
          // times the expected number of retries.
          expect(dcRT.elapsed, greaterThan(ms1 * maxI));
          // At least one delay should have exceeded the cap, so total
          // elapsed time should definitely exceed that value (and then some).
          expect(dcRT.elapsed, greaterThan(capAfter));
          // cappedRetry should have stopped increasing (well) before msCapped
          // retries.
          expect(cappedRetry, lessThan(msCapped));
        });
    });
  });
}
