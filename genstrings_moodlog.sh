#!/bin/sh
find ./ "(" -name "*.m" -or -name "*.swift" ")" -print0 | xargs -0 genstrings -o MoodLog/en.lproj
