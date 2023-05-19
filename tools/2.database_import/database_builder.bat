@echo off
pushd %~dp0
cd ..\..
dart .\tools\2.database_import\main.dart %* & ^
popd
