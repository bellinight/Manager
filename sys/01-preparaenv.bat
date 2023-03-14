@echo OFF
:: Para e remove Serviço existente para atualização
C:\Mercadologic\Manager\sys\nssm\win64\nssm stop processa_manager >> C:\Mercadologic\log\01-preparaenv.log
C:\Mercadologic\Manager\sys\nssm\win64\nssm remove processa_manager confirm >> C:\Mercadologic\log\01-preparaenv.log
:: Deleta a tarefa para evitar problemas na instalação.
schtasks /delete /tn RestartManager /f >> C:\Mercadologic\log\01-preparaenv.log
::Update_Manager
if exist "C:\Mercadologic\Manager\EnviarDadosManager.ps1" (
echo Update_Manager >> C:\Mercadologic\log\01-preparaenv.log
:: Copia de arquivos do Manager
xcopy /E /Y /F c:\Mercadologic\Manager\ClienteLoja.config C:\Mercadologic\temp\files  >> C:\Mercadologic\log\01-preparaenv.log
xcopy /E /Y /F c:\Mercadologic\Manager\DadosServidor.config C:\Mercadologic\temp\files >> C:\Mercadologic\log\01-preparaenv.log
xcopy /E /Y /F c:\Mercadologic\Manager\Servicos.config C:\Mercadologic\temp\files >> C:\Mercadologic\log\01-preparaenv.log
:: Apaga pasta com arquivos antigos
echo Deletando arquivos >> C:\Mercadologic\log\01-preparaenv.log  
del /s /q  C:\Mercadologic\Manager\*.* >> C:\Mercadologic\log\01-preparaenv.log
::rd /s /q  C:\Mercadologic\Manager\ >> C:\Mercadologic\log\01-preparaenv.log
echo Atualizando arquivos do Manager >> C:\Mercadologic\log\01-preparaenv.log
::copia arquivos salvos na temp
xcopy /E /Y /F C:\Mercadologic\temp\*.* C:\Mercadologic\Manager  >> C:\Mercadologic\log\01-preparaenv.log
::Cria tarefa agendando reinicio do serviço(Necessita Privilegios Altos)
schtasks /create /tn RestartManager /tr C:\Mercadologic\Manager\sys\restart-servico.bat /sc DAILY /RI 60 /du 24:00 /np /f /RL HIGHEST >> C:\Mercadologic\log\01-preparaenv.log
:: Atualização do Powershell
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\Mercadologic\Manager\sys\atualizacoes.ps1" >> C:\Mercadologic\log\01-preparaenv.log
exit
)  ELSE (
	goto novomanager
)
::Instala Manager Novo
:novomanager
echo Criando pasta do Manager >> C:\Mercadologic\log\01-preparaenv.log
:: Cria pasta princial do sistema
mkdir C:\Mercadologic\Manager >> C:\Mercadologic\log\01-preparaenv.log
timeout /t 5 /nobreak
:: Copia arquivos da temp(padrão) para o Manager
xcopy /E /Y /F C:\Mercadologic\temp\*.* C:\Mercadologic\Manager  >> C:\Mercadologic\log\01-preparaenv.log
timeout /t 5 /nobreak
::Cria tarefa agendando reinicio do serviço(Necessita Privilegios Altos)
schtasks /create /tn RestartManager /tr C:\Mercadologic\Manager\sys\restart-servico.bat /sc DAILY /RI 60 /du 24:00 /np /f /RL HIGHEST
:: Atualização do Powershell
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\Mercadologic\Manager\sys\atualizacoes.ps1" >> C:\Mercadologic\log\01-preparaenv.log
exit