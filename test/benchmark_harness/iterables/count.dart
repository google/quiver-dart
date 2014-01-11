library quiver.iterables.benchmarks.count;

import '../../../lib/iterables.dart' as iterables;

import 'package:benchmark_harness/benchmark_harness.dart';

class CountBenchmark extends BenchmarkBase {
  const CountBenchmark() : super("iterables.count");

  final List<num> li = new List<num>();

  void run() {
    for (var x in iterables.count().take(50000)) {
      li.add(x);
    }
    li.clear();
  }
}