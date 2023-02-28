@echo off

c:\Mercadologic\Manager\sys\nssm\win64\nssm

c:\Mercadologic\Manager\sys\nssm\win64\nssm install processa_manager "C:\Mercadologic\Manager\incia_ps1.bat" >> C:\Mercadologic\log\03-preparanssm.log

nssm set processa_manager Application C:\Mercadologic\Manager\incia_ps1.bat
::nssm set processa_manager AppDirectory C:\Mercadologic\Manager >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager DisplayName Processa Manager >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager Description Sistema de Coleta de Dados do Mercadologic >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager Start SERVICE_DELAYED_AUTO_START >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager ObjectName LocalSystem >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppPriority HIGH_PRIORITY_CLASS >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppNoConsole 0 >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppAffinity All >> C:\Mercadologic\log\03-preparanssm.log
::c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppStdout C:\Mercadologic\log\serviconssm.log
::c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppStderr C:\Mercadologic\log\serviconssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppStopMethodSkip 6 >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppStopMethodConsole 1000 >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppStopMethodWindow 1500 >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppStopMethodThreads 1500 >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppThrottle 1000 >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppExit Default Restart >> C:\Mercadologic\log\03-preparanssm.log
c:\Mercadologic\Manager\sys\nssm\win64\nssm set processa_manager AppRestartDelay 2 >> C:\Mercadologic\log\03-preparanssm.log
timeout /t 5 /nobreak
c:\Mercadologic\Manager\sys\nssm\win64\nssm start processa_manager >> C:\Mercadologic\log\03-preparanssm.log

::del /s /q  C:\Mercadologic\temp\*.* >> C:\Mercadologic\log\folderManager.log
::rd /s /q  C:\Mercadologic\temp >> C:\Mercadologic\log\folderManager.log
::del /s /q  C:\Mercadologic\Manager\sys\*.* >> C:\Mercadologic\log\folderManager.log
::rd /s /q  C:\Mercadologic\Manager\sys >> C:\Mercadologic\log\folderManager.log

timeout /t 5 /nobreak
exit