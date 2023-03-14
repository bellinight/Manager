echo off
:: Aplica path para o NSSM
SETX -m Path "%Path%;C:\Mercadologic\Manager\sys\nssm\win64;C:\Program Files\PostgreSQL\14\bin"
::Verificando Powershell
IF EXIST "%ProgramFiles(x86)%\PowerShell\7\pwsh.exe" (
xcopy /E /Y /F C:\Mercadologic\Manager\sys\ps1-var\incia_ps1.bat C:\Mercadologic\Manager\  >> C:\Mercadologic\log\02-servicoinstall.log
timeout /t 5 /nobreak
goto proximo
) ELSE (
	goto proximo
)
:proximo  
:: Confere se PsqlODBC esta instalado na maquina.
IF EXIST "%programfiles%\psqlODBC\1202\psqlodbc30a.dll" (
	goto saida
) ELSE (
	goto continua
)
:continua
::Executa instalação do ODBC
msiexec /i "C:\Mercadologic\Manager\programas\psqlodbc_x64.msi" /qb! /l C:\Mercadologic\log\02-servicoinstall.log
timeout /t 5 /nobreak
:saida
::Encerrar processos
exit