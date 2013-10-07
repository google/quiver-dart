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

part of quiver.collection;

/**
 * Shuffles a list using the
 * [modern Knuth shuffle](http://en.wikipedia.org/wiki/Knuth_shuffle#The_modern_algorithm).
 * The list is modified, and the list is returned for convenience.
 */
List shuffle(final List list, [Random random]) {
  if (random == null) {
    random = new Random();
  }
  
  for (int i = list.length - 1; i > 0; i--) {
    int j = random.nextInt(i+1);
    var temp = list[i];
    list[i] = list[j];
    list[j] = temp; 
  }
  
  return list;
}

