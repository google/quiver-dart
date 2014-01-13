library quiver.iterables.range_benchmarks;

import 'package:quiver/iterables.dart' as iterables;

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

referenceRange(int start, int stop, int step) {
  return new Iterable.generate(stop - start, (i) => start + i * step);
}

class ReferenceRangeBenchmark extends BenchmarkBase {
  const ReferenceRangeBenchmark() : super("iterables.range (reference impl)");

  final List<num> li = new List<num>();

  void run() {
    for (var x in referenceRange(0, 50000, 2)) {
      li.add(x);
    }
    li.clear();
  }
}