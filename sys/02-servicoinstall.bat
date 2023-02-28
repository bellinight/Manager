@echo off

::choco
:: Instala gerenciador de serviços NSSM
::choco install nssm -y >> C:\Mercadologic\log\02-servicoinstall.log
:: Aplica path para o NSSM
SETX -m Path "%Path%;C:\Mercadologic\Manager\sys\nssm\win64;C:\Program Files\PostgreSQL\14\bin"

:: Confere se Postgresql esta instalado na maquina.
IF EXIST "%programfiles%\psqlODBC\1202\psqlodbc30a.dll" (

	exit
) ELSE (
	goto continua
)

:continua
::Executa instalação do ODBC
msiexec /i "C:\Mercadologic\Manager\programas\psqlodbc_x64.msi" /qb! /l C:\Mercadologic\log\02-servicoinstall.log
timeout /t 5 /nobreak

exit