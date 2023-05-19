@echo off
pushd %~dp0
dart .\main.dart %* & ^
popd
