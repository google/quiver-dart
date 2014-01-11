library quiver.iterables.benchmarks.range;

import '../../../lib/iterables.dart' as iterables;

import 'package:benchmark_harness/benchmark_harness.dart';

class RangeBenchmark extends BenchmarkBase {
  const RangeBenchmark() : super("iterables.range");

  final List<num> li = new List<num>();

  void run() {
    for (var x in iterables.range(0, 50000, 2)) {
      li.add(x);
    }
    li.clear();
  }
}