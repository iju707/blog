#!/bin/bash
cd public
git init
git add -A
git commit -m "deploy $1"
git push -f https://github.com/iju707/blog.git master:gh-pages