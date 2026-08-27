set ND=__%date:~0,4%%date:~5,2%%date:~8,2%
set sec=%TIME:~3,2%%TIME:~6,2%
set h=%TIME:~0,2%
if %h% leq 9 (set h=0%h:~1,1%)
set FD=%ND%%h%%sec%

md %FD%
GameRoom.exe -workdir %cd% -writable-path %FD% -scale 0.8