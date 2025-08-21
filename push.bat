@echo off
set /p commitMessage="Enter commit message: "
git add .
git commit -m "%commitMessage%"
git push
