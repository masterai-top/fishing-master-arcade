@echo off
setlocal Enabledelayedexpansion

set base=__base
set src=%~dp0
set dst=%~dp0src\ui
set plugin=../../Tool/ui_plugin/

cd %plugin%
python gen_plugin_ui.py %src% %dst% %base%
