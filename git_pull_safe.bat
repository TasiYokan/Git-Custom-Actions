@ECHO off

REM Updaet master branch then rebase local branch to latest version.
REM Be sure the master branch is clean!"
git checkout master
git pull origin master
git checkout local
git rebase master
IF %ERRORLEVEL% NEQ 0 (
    SET /A command_result=%ERRORLEVEL%
)

EXIT /B %command_result%
REM Done