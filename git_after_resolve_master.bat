@ECHO OFF

git checkout master
git branch local_backup_tmp
git checkout local_backup_tmp
git rebase --onto local_backup local local_backup_tmp
git checkout local_backup
git merge local_backup_tmp
git branch -d local_backup_tmp
REM Some local changes won't be saved on local_backup
git branch -D local
git checkout master
git branch local
git checkout local

EXIT /B %command_result%
REM Done