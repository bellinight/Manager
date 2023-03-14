:: Incia ferramenta na versão Powershell 1.0
Taskkill /IM powershell.exe /f
timeout /t 5 /nobreak
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\Mercadologic\Manager\EnviarDadosManager.ps1"
timeout /t 5 /nobreak
Taskkill /IM powershell.exe /f
exit