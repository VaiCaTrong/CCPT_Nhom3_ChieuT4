@echo off
set PLUGIN_PATH=%1
set TEMP_FILE=%2

echo Fixing %PLUGIN_PATH%...
echo y | copy %TEMP_FILE% "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\%PLUGIN_PATH%\android\build.gradle" > nul
echo Done!
