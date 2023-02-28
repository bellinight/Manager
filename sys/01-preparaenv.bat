@echo OFF

:: Atualização do Powershell
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\Mercadologic\Manager\sys\atualizacoes.ps1" >> C:\Mercadologic\log\01-preparaenv.log

::Cria tarefa agendando reinicio do serviço(Necessita Privilegios Altos)
schtasks /create /tn RestartManager /tr C:\Mercadologic\Manager\sys\restart-servico.bat /sc hourly /mo 1 

::Verifica se chocolatey esta instalada
if not exist "%ALLUSERSPROFILE%\chocolatey\bin\choco.exe" (
  @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin" >> C:\Mercadologic\log\01-preparaenv.log
)
:: Confere a instalação da chocolatey
@"%ALLUSERSPROFILE%\chocolatey\bin\choco.exe" -v >nul 2>&1
if %ERRORLEVEL% EQU 0 (
  echo Chocolatey instalado com sucesso. Prosseguindo com outras etapas... >> C:\Mercadologic\log\01-preparaenv.log
) else (
  echo Erro ao instalar o Chocolatey. Efetue a instalação manualmente pelo site. >> C:\Mercadologic\log\01-preparaenv.log
  goto proximaetapa
)

:proximaetapa
IF EXIST "c:\Mercadologic\Manager\EnviarDadosManager.ps1" (
::Update_Manager
:: Instala Chocolatey para instalação de pacotes de forma avançada
::@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) >> C:\Mercadologic\log\01-preparaenv.log
timeout /t 5 /nobreak
::@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin" >> C:\Mercadologic\log\01-preparaenv.log
:: Copia arquivos de configuração para pasta temporria
echo Update_Manager >> C:\Mercadologic\log\01-preparaenv.log
::del /s /q  C:\Mercadologic\temp\*.* >> C:\Mercadologic\log\folderManager.log
:: Copia arquivos do Manager com sisitema de serviço instalado.
xcopy /E /Y /F c:\Mercadologic\Manager\files\ClienteLoja.config C:\Mercadologic\temp\files  >> C:\Mercadologic\log\01-preparaenv.log
xcopy /E /Y /F c:\Mercadologic\Manager\files\DadosServidor.config C:\Mercadologic\temp\files >> C:\Mercadologic\log\01-preparaenv.log
xcopy /E /Y /F c:\Mercadologic\Manager\files\Servicos.config C:\Mercadologic\temp\files >> C:\Mercadologic\log\01-preparaenv.log
:: Copia de arquivos do Manager sem serviço instalado(Via Agendador)
xcopy /E /Y /F c:\Mercadologic\Manager\ClienteLoja.config C:\Mercadologic\temp\files  >> C:\Mercadologic\log\01-preparaenv.log
xcopy /E /Y /F c:\Mercadologic\Manager\DadosServidor.config C:\Mercadologic\temp\files >> C:\Mercadologic\log\01-preparaenv.log
xcopy /E /Y /F c:\Mercadologic\Manager\Servicos.config C:\Mercadologic\temp\files >> C:\Mercadologic\log\01-preparaenv.log
echo Deletando arquivos >> C:\Mercadologic\log\01-preparaenv.log
:: Apaga pasta com arquivos antigos
del /s /q  C:\Mercadologic\Manager\*.* >> C:\Mercadologic\log\01-preparaenv.log
::rd /s /q  C:\Mercadologic\Manager\ >> C:\Mercadologic\log\01-preparaenv.log
echo Atualizando arquivos do Manager >> C:\Mercadologic\log\01-preparaenv.log
::copia arquivos salvos na temp
xcopy /E /Y /F C:\Mercadologic\temp\*.* C:\Mercadologic\Manager  >> C:\Mercadologic\log\01-preparaenv.log


exit    
)  ELSE (
	goto novomanager
)

:novomanager
:: Cria pasta princial do sistema
mkdir C:\Mercadologic\Manager >> C:\Mercadologic\log\01-preparaenv.log
:: Instala Chocolatey para instalação de pacotes de forma avançada
::@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) >> C:\Mercadologic\log\01-preparaenv.log
timeout /t 5 /nobreak
::@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin" >> C:\Mercadologic\log\01-preparaenv.log
echo Novo Manager >> C:\Mercadologic\log\01-preparaenv.log
:: Copia arquivos da temp para o manager
xcopy /E /Y /F C:\Mercadologic\temp\*.* C:\Mercadologic\Manager  >> C:\Mercadologic\log\01-preparaenv.log

timeout /t 5 /nobreak

exit