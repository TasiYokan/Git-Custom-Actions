@ECHO off
SETLOCAL enabledelayedexpansion

REM Merge local to changes on master branch (if any) before push

REM Optional
git checkout local
git fetch origin master

REM Check if remote updated while we have local changes. If yes, we will record it to find the right commit to rebase
SET result_output=git_output.txt
git rev-list --count master..origin/master>%result_output%
SET /P behind_count=<%result_output%
DEL %result_output%
ECHO %behind_count%
SET /A root_commit=%behind_count%+1
ECHO %root_commit%

git rebase master

IF %ERRORLEVEL% EQU 0 (
    ECHO [Merge local changes to master to push.]
    git checkout master
    git pull origin master
    IF !ERRORLEVEL! NEQ 0 (
        ECHO [You need merge changes on remote first]
        SET /A command_result=!ERRORLEVEL!
        GOTO ERROREXIT
    )
    REM Squash all local changes to one when submit to master
    git merge --squash local
    IF !ERRORLEVEL! NEQ 0 (
        ECHO [You need merge changes between remote and local first]
        SET /A command_result=!ERRORLEVEL!
        GOTO ERROREXIT
    )
    REM Reuse the commit message from local branch's HEAD
    git commit --reuse-message=local@{0}
    
    git push origin master

    git checkout local
    REM TODO: This will clean all local git history...
    REM git reset master@{0}

    git rev-parse --verify --quiet local_backup
    IF !ERRORLEVEL! EQU 128 (
        ECHO [local_backup doesn't exist! Simply rename local branch to local_backup and create a new one later.]
        git branch -m local local_backup
    ) ELSE (
        REM Get all local changes and rebase onto commit before squash merge on master
        git rebase --onto master@{1} master@{%root_commit%} local

        REM Rebase commits from master HEAD~1 to local HEAD onto local_backup
        git rebase --onto local_backup master@{%root_commit%} local
        IF !ERRORLEVEL! NEQ 0 (
            SET /A command_result=!ERRORLEVEL!
        )
        ECHO [Merge local to local_backup with fast-forward]
        git checkout local_backup
        git merge local
        git branch -d local
    )
    git checkout master
    git branch local
    git checkout local
) ELSE (
    SET /A command_result=!ERRORLEVEL!
    ECHO [Couldn't rebase due to changes on remote.]
    REM To let the merge happen on local
    git rebase --abort
    git checkout master
    git pull origin master
    git checkout local
    git merge master --no-ff
)

EXIT /B %command_result%
REM Done

:ERROREXIT:
EXIT /B 1