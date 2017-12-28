@ECHO off

REM Create a new local branch and check it out immediately

git branch local
IF %ERRORLEVEL% NEQ 0 (
    SET /A command_result=%ERRORLEVEL%
)
git checkout local

EXIT /B %command_result%
REM Done