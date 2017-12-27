@ECHO OFF

REM When after merging changes on master to local, we will append the commit to the head of master
REM So that master will be at the same place as local and ready to push to remote
git checkout master
git fetch origin master
git cherry-pick %~f1
IF %ERRORLEVEL% NEQ 0 (
    ECHO [Force to get merged version on local to update master.]
    git merge --strategy-option theirs local
)
git checkout local
git rebase master

REM Done