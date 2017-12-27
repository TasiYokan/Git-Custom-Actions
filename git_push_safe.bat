@ECHO off

REM Merge local to changes on master branch (if any) before push

REM Optional
git checkout local
git fetch origin master
git rebase master
IF %ERRORLEVEL% EQU 0 (
    ECHO [Merge local changes to master to push.]
    git checkout master
    git pull origin master
    git merge local
    git push origin master
    git checkout local
    git rebase master
) ELSE (
    ECHO [Couldn't rebase due to changes on remote.]
    REM To let the merge happen on local
    git rebase --abort
    git checkout master
    git pull origin master
    git checkout local
    git merge master --no-ff
)

REM Done