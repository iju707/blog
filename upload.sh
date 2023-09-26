#!/bin/bash
date=$(date '+%Y-%m-%d %H:%M:%S')

cd public
git init
git add -A
git commit -m "deploy $date"
git push -f https://github.com/iju707/blog.git master:gh-pages