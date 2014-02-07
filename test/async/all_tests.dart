// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library quiver.async.all_tests;

import 'countdown_timer_test.dart' as countdown_timer;
import 'create_timer_test.dart' as create_timer;
import 'future_group_test.dart' as future_group;
import 'iteration_test.dart' as iteration;
import 'stream_router_test.dart' as stream_router;

main() {
  countdown_timer.main();
  create_timer.main();
  future_group.main();
  iteration.main();
  stream_router.main();
}
