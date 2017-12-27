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
    REM Squash all local changes to one when submit to master
    git merge --squash local
    REM Reuse the commit message from local branch's HEAD
    git commit --reuse-message=local@{0}
    
    git push origin master

    REM TODO: This will clean all local git history...
    git checkout local
    git reset master@{0}
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