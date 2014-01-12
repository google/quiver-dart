library quiver.iterables.benchmarks;

import 'package:benchmark_harness/benchmark_harness.dart';
import 'count.dart' as count;
import 'range.dart' as range;
import 'groupby.dart' as groupby;
import 'slice.dart' as slice;
import 'sort.dart' as sort;

List<BenchmarkBase> defineBenchmarks() {
  return
      [ //new count.CountBenchmark(),
        //new range.RangeBenchmark(),
        //new groupby.LazyGroupBenchmark(),
        //new slice.SliceBenchmark(),
        //new slice.ReferenceSliceBenchmark(),
        new sort.ReferenceSortBenchmark(),
        new sort.SortBenchmark()
      ];
}