library quiver.slice_benchmarks;

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:quiver/iterables.dart';
import 'data.dart' as benchmark_data;

class SliceBenchmark extends BenchmarkBase {
  SliceBenchmark() : super("iterables.slice");

  List<String> li = new List<String>();

  void run() {
    for (var s in slice(benchmark_data.groupData, 0, 10000,2)) {
      li.add(s);
    }
    li.clear();
  }
}

referenceSlice(Iterable iterable, start, int stop, step) {
  List li = new List.from(iterable, growable: false);
  var len = li.length;
  return range(start, (len < stop) ? len : stop, step)
      .map((i) => li[i]);
}

class ReferenceSliceBenchmark extends BenchmarkBase {
  ReferenceSliceBenchmark() : super("iterables.slice (reference impl)");

  List<String> li = new List<String>();
  void run() {
    for (var s in referenceSlice(benchmark_data.groupData, 0, 10000, 2)) {
      li.add(s);
    }
    li.clear();
  }
}
