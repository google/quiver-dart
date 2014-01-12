library quiver.iterables.groupby_benchmark;

import 'package:quiver/iterables.dart' as iterables;
import 'package:benchmark_harness/benchmark_harness.dart';
import 'data.dart' as benchmark_data;

class LazyGroupBenchmark extends BenchmarkBase {
  LazyGroupBenchmark() : super("iterables.groupby.lazy");

  List li = new List<iterables.Group<int, String>>();

  void run() {
    for (var grp in iterables.groupBy(benchmark_data.groupData, key: (x) => x.length))
        li.add(grp);
    li.clear();
  }
}