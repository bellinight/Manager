:: Incia ferramenta na versão Powershell 1.0

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\Mercadologic\Manager\EnviarDadosManager.ps1"
Taskkill /IM powershell.exe /f
:: Incicia ferramenta na versão 7 do Powershell(Retire o comentario apar usar e lembre de comentar o anterior)

:: @"C:\Program Files\PowerShell\7\pwsh.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\Mercadologic\Manager\EnviarDadosManager.ps1"
Taskkill /IM pwsh.exe /f
exit