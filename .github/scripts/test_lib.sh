#!/bin/bash

set -eo pipefail

xcodebuild -workspace Example/Odeum.xcworkspace \
            -scheme Odeum-Example \
            -destination platform=iOS\ Simulator,OS=14.5,name=iPhone\ 11 \
            clean test | xcpretty
