@ECHO off

REM Updaet master branch then rebase local branch to latest version.
REM Be sure the master branch is clean!"
git checkout master
git pull origin master
git branch master_tmp
git checkout master_tmp
git rebase --onto local_backup local master_tmp
git checkout local_backup
git merge master_tmp
git branch -d master_tmp
git checkout local
git rebase master
IF %ERRORLEVEL% NEQ 0 (
    SET /A command_result=%ERRORLEVEL%
)

EXIT /B %command_result%
REM Done