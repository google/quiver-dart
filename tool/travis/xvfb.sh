#!/bin/bash

# Copyright (c) 2018, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
"t=0; until (xdpyinfo -display :99 &> /dev/null || test $t -gt 10); do sleep 1; let t=$t+1; done"
