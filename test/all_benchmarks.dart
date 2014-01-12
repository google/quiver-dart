library quiver.all_benchmarks;

import 'package:benchmark_harness/benchmark_harness.dart';

import 'benchmark_harness/quiver_benchmark.dart';
import 'benchmark_harness/iterables/all_benchmarks.dart' as iterables;

void main() {
  List<BenchmarkBase> allBenchmarks = new List();
  allBenchmarks.addAll(iterables.defineBenchmarks());
  loadDefaultContext()
      .then((BenchmarkExecuteContext benchmarkContext) {
        allBenchmarks.forEach((benchmark) {
          QuiverBenchmark qb = new QuiverBenchmark(benchmark, benchmarkContext);
          qb.report();
          print("\n\n");
        });
        benchmarkContext.storeContext();
      });
}