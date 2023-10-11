@echo off

for /f "tokens=*" %%i in ('powershell -c "get-date -format \"yyyy-MM-dd HH:mm:ss\""') do (
  set currentTime=%%i
)

cd public
git init
git config core.autocrlf false
git add -A
git commit -m "deploy %currentTime%"
git push -f https://github.com/iju707/blog.git master:gh-pages