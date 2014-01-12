library quiver.benchmark_harness;


import 'dart:async';
import 'dart:io' as io;
import 'dart:convert' show JSON, UTF8;
import 'package:benchmark_harness/benchmark_harness.dart';

import '../../lib/iterables.dart';

Future<BenchmarkExecuteContext> loadDefaultContext() =>
    BenchmarkExecuteContext.loadContext(new io.File("./benchmark_results.json"));

class BenchmarkExecuteContext {
  static Future<BenchmarkExecuteContext> loadContext(io.File benchmarkResultStore) {
    return benchmarkResultStore
        .readAsString(encoding: UTF8)
        .then((results) {
          return new BenchmarkExecuteContext(
              benchmarkResultStore,
              JSON.decode(results));
        })
        .catchError((e) {
          benchmarkResultStore.create();
          return new BenchmarkExecuteContext(
              benchmarkResultStore,
              {});
        },
        test: (e) => e is io.FileSystemException);
  }

  final io.File resultStore;
  final Map results;
  const BenchmarkExecuteContext(io.File this.resultStore, Map this.results);

  List resultsFor(QuiverBenchmark benchmark) {
    List results = this.results[benchmark.name];
    if (results == null) {
      return new List.filled(5, -1.0);
    }
    return results;
  }

  void updateResultsFor(QuiverBenchmark benchmark, double currentRun) {
    List<double> results = new List.from(resultsFor(benchmark));
    results.removeLast();
    results.insert(0, currentRun);
    this.results[benchmark.name] = results;
  }
  Future storeContext() {
    return resultStore
        .writeAsString(JSON.encode(results),
                       encoding: UTF8);
  }
}

class QuiverBenchmark implements BenchmarkBase {
  final BenchmarkBase delegate;
  final BenchmarkExecuteContext executeContext;
  const QuiverBenchmark(BenchmarkBase this.delegate, BenchmarkExecuteContext this.executeContext);

  void report() {
    print("Running benchmark ($name)...");
    var currResult = measure();
    var file = new io.File("./benchmark_results");
    var title = "$name results";
    print(title);
    print(cycle([["="]]).expand((i) => i).take(title.length).join());
    var prevResults = executeContext.resultsFor(this);
    fmtPrev(i) => "Run (current - ${i + 1}): "
                  + (prevResults[i] >= 0 ? "${prevResults[i]} us." : "No data for run");
    for (int i=4; i>=0;i--) {
      print(fmtPrev(i));
    }
    print("Current run:       ${currResult} us.");
    var runResults = [[currResult], prevResults]
        .expand((i) => i)
        .where((r) => r >= 0);
    var avgResult = runResults.fold(0.0, (s, e) => s + e) / runResults.length;
    print("Average run:       ${avgResult}");
    executeContext.updateResultsFor(this, currResult);
  }

  String get name => delegate.name;

  void setup() => delegate.setup();
  void teardown() => delegate.teardown();
  void warmup() => delegate.warmup();
  void run() => delegate.run();
  double measure() => delegate.measure();
  void exercise() => delegate.exercise();

}