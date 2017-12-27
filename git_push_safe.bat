@ECHO off

REM Merge local to changes on master branch (if any) before push

REM I don't know why return value will change to 0 if I put it at line 29...
git rev-parse --verify --quite local_backup
SET /A local_backup_exists=%ERRORLEVEL%

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

    git checkout local
    REM TODO: This will clean all local git history...
    REM git reset master@{0}

    ECHO %local_backup_exists%
    IF %local_backup_exists% EQU 128 (
        ECHO [local_backup doesn't exist! Simply rename local branch to local_backup and create a new one later.]
        git branch -m local local_backup
    ) ELSE (
        ECHO [Rebaes local_backup success! Merge local to local_backup and delete local, finally create a new one later.]
        git rebase local_backup
        git checkout local_backup
        git merge local
        git branch -d local
    )
    git checkout master
    git branch local
    git checkout local
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