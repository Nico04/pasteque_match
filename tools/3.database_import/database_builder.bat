@echo off
pushd %~dp0
cd ..\..
dart .\tools\3.database_import\main.dart %* & ^
popd
