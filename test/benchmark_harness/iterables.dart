library quiver.iterables.benchmarks;

import 'package:benchmark_harness/benchmark_harness.dart';
import 'iterables/count.dart' as count;
import 'iterables/range.dart' as range;

List<BenchmarkBase> defineBenchmarks() {
  return
      [ new count.CountBenchmark(),
        new range.RangeBenchmark()
      ];
}