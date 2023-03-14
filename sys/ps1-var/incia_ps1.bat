:: Incicia ferramenta na versão 7 do Powershell(Retire o comentario apar usar e lembre de comentar o anterior)
Taskkill /IM pwsh.exe /f
timeout /t 5 /nobreak
@"%ProgramFiles(x86)%\PowerShell\7\pwsh.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\Mercadologic\Manager\EnviarDadosManager.ps1"
timeout /t 5 /nobreak
Taskkill /IM pwsh.exe /f
exit