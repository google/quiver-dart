library quiver.iterables.sort_benchmarks;

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:quiver/iterables.dart';
import 'data.dart' as benchmark_data;

class SortBenchmark extends BenchmarkBase {
  SortBenchmark() : super("iterables.sort");

  List<String> li = new List<String>();

  void run() {
    for (var s in sort(benchmark_data.groupData).where((s) => s.length % 2 == 0)) {
      li.add(s);
    }
    li.clear();
  }
}

referenceSort(Iterable iterable, {Comparator comparator: Comparable.compare}) {
  List li = new List.from(iterable, growable: false);
  li.sort(comparator);
  return li;
}

class ReferenceSortBenchmark extends BenchmarkBase {
  ReferenceSortBenchmark() : super("iterables.sort (reference impl)");

  List<String> li = new List<String>();
  void run() {
    for (var s in referenceSort(benchmark_data.groupData).where((s) => s.length % 2 == 0)) {
      li.add(s);
    }
    li.clear();
  }
}