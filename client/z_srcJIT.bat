@echo off
setlocal Enabledelayedexpansion

set folder=%~dp0
set cpath=%folder%Resource\client\win32\

cocos luacompile --disable-compile -e -k doudizhuverkey -b gamesign -s %folder%src -d %cpath%src

