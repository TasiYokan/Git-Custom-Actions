@ECHO OFF

REM When after merging changes on master to local, we will append the commit to the head of master
REM So that master will be at the same place as local and ready to push to remote
git checkout master
git fetch origin master
git cherry-pick %~f1
IF %ERRORLEVEL% NEQ 0 (
    REM SET /A command_result=%ERRORLEVEL%
    ECHO [Force to get merged version on local to update master.]
    git merge --strategy-option theirs local
)
git checkout local
git rebase master

git checkout master
git checkout -b local_backup_tmp
git rebase --onto local_backup local@{1} local_backup_tmp
git cherry-pick master@{0} -m 1

git checkout local_backup
git merge local_backup_tmp
git branch -d local_backup_tmp

REM Is push to remote ok?
git push origin master

EXIT /B %command_result%
REM Done