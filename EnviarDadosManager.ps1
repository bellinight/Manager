# Local do script
$path_atual = split-path -parent $MyInvocation.MyCommand.Definition
$versao_ps1='1.3.6S'

# Faz download do arquivo PS1 do servidor
#Invoke-WebRequest -uri http://manager.processa.info/ArquivosMercadoLogic/EnviarDadosManager.ps1 -OutFile $path_atual\EnviarDadosManager.ps1

# Código do cliente e da loja no Manager
$Text = Get-Content -Path $path_atual\files\ClienteLoja.config
$Text.GetType() | Format-Table -AutoSize

foreach ($element in $Text) 
{ 
    New-Variable -Name ($element.Split('=') | Select-Object -first 1) -Value ($element.Split('=') | Select-Object -last 1)
}

# Dados de conexão com Postgre do Concentrador
$Text = Get-Content -Path $path_atual\files\DadosServidor.config
$Text.GetType() | Format-Table -AutoSize

foreach ($element in $Text) 
{ 
    New-Variable -Name ($element.Split('=') | Select-Object -first 1) -Value ($element.Split('=') | Select-Object -last 1)
}

$cnString = "DRIVER={PostgreSQL Unicode(x64)};DATABASE=$database;SERVER=$server_ip;PORT=$port;UID=$user;PWD=$pass;Timeout=2;"

$conn_con = New-Object -comobject ADODB.Connection
$conn_con.Open($cnString, $user, $pass)

# Versão concentrador
$recordset = $conn_con.Execute("SELECT versao_sistema FROM public.versao limit 1;")
$con_ve = $recordset.Fields['versao_sistema'].value

# Atualização carga no Concentrador
try {
    # versões superiores à 13.7.0
    $recordset = $conn_con.Execute("SELECT id_atualizacao, CAST(dh_fim_publicacao AS text) AS dh_fim_publicacao FROM carga.semaforo_loja ORDER BY id_atualizacao DESC LIMIT 1;")
    $dia_atu = $recordset.Fields['dh_fim_publicacao'].value.substring(8,2)
    $mes_atu = $recordset.Fields['dh_fim_publicacao'].value.substring(5,2)
    $ano_atu = $recordset.Fields['dh_fim_publicacao'].value.substring(0,4)
    $hora_atu = $recordset.Fields['dh_fim_publicacao'].value.substring(11,5)

    $atu_id = $recordset.Fields['id_atualizacao'].value
} catch {
    # versões anteriores à 13.7.0
    $recordset = $conn_con.Execute("SELECT descricao FROM public.atualizacao ORDER BY id DESC LIMIT 1;")
    $dia_atu = $recordset.Fields['descricao'].value.substring(0,2)
    $mes_atu = $recordset.Fields['descricao'].value.substring(2,2)
    $ano_atu = $recordset.Fields['descricao'].value.substring(4,4)
    $hora_atu = $recordset.Fields['descricao'].value.substring(9,5)

    $atu_id = -1
}

$ult_ca = $dia_atu + '/' + $mes_atu + '/' + $ano_atu + ' ' + $hora_atu

# Verifica em qual drive esta instalado o Postgre no Concentrador
# Pega os dados desse drive
# $dirpg = pg_config --bindir     <=> Ao usar isso no Porgresso deu erro no pg_config
# $drive = $dirpg.substring(0,2)
$drive = 'C:'
$disk = Get-CimInstance -ClassName Win32_LogicalDisk -filter "DeviceID='$drive'"

$disksResult = $disk | Foreach-Object {
	$esp_li = $_.FreeSpace
	$tam_hd = $_.Size
}

# Verifica o status dos serviços no Concentrador
$Text = Get-Content -Path $path_atual\files\Servicos.config
$Text.GetType() | Format-Table -AutoSize

foreach ($element in $Text) 
{ 
    $variavel = ($element.Split('=') | Select-Object -first 1)
	$valor = get-service ($element.Split('=') | Select-Object -last 1)
	
	New-Variable -Name $variavel -Value $valor.Status
}

# Pega o IP dos pdvs
try {
	# versões superiores à 13.7.0
	$recordset = $conn_con.Execute("SELECT pdv.id
									, pdv.descricao
									, pdv.desativado
									, pdv.ip
									, semaforo_pdv.id_atualizacao
									, CAST(semaforo_pdv.dh_atualizacao_finalizada AS text) AS dh_atualizacao_finalizada
								FROM public.pdv
								JOIN carga.semaforo_pdv ON semaforo_pdv.identificador_pdv = pdv.identificador
								ORDER BY pdv.id
							")
	$nova_versao = 1
} catch {
	# versões anteriores à 13.7.0
	$recordset = $conn_con.Execute("SELECT id
										, ip
										, descricao
										, desativado 
									FROM public.pdv 
									ORDER BY id
							")
	$nova_versao = 0
}

# Verifica a versão e carga de cada PDV
while ($recordset.EOF -ne $True) {
    $pdv_at_id = -1
	
	foreach ($field in $recordset.Fields) {
    	$recordset.fields | ForEach-Object {
    		if($_.name -eq 'id') {
    			$pdv_id=$_.value
    		}

			if($_.name -eq 'descricao') {
    			$pdv=$_.value
    		}
			
			if($_.name -eq 'ip') {
    			$server_ipPdv=$_.value
    		}
			
			if($_.name -eq 'desativado') {
    			$des_pv=$_.value
    		}
			
			# versões posteriores à 13.7.0
			# Atualização carga do PDV
			if($_.name -eq 'dh_atualizacao_finalizada') {
				if([String]::IsNullOrEmpty($_.value)) {
					$pdv_at=''
				} else {
					$dia_atuPdv = $_.value.substring(8,2)
					$mes_atuPdv = $_.value.substring(5,2)
					$ano_atuPdv = $_.value.substring(0,4)
					$hora_atuPdv = $_.value.substring(11,5)
				
					$pdv_at=$dia_atuPdv + '/' + $mes_atuPdv + '/' + $ano_atuPdv + ' ' + $hora_atuPdv
				}
			}
            if($_.name -eq 'id_atualizacao') {
                if([String]::IsNullOrEmpty($_.value)) {
                    $pdv_at_id = -1
                } else {
    		    	$pdv_at_id = $_.value
    		    }
            }
    	}
    }
	
	# Dados de conexão com Postgre do PDV
	$databasePdv='DBPDV'
	$portPdv='5432'
	$userPdv='postgres'
	$passPdv='local'
	
	$cnStringPdv = "DRIVER={PostgreSQL Unicode(x64)};DATABASE=$databasePdv;SERVER=$server_ipPdv;PORT=$portPdv;UID=$userPdv;PWD=$passPdv;Timeout=2;"
	
	$pdv_ve = ''

	try {
		$connPdv = New-Object -comobject ADODB.Connection
		$connPdv.Open($cnStringPdv, $userPdv, $passPdv)
		
		# Versão PDV
		$recordsetPdv = $connPdv.Execute("SELECT versao_sistema FROM public.versao limit 1;")
		$pdv_ve=$recordsetPdv.Fields['versao_sistema'].value
		
		# versões anteriores à 13.7.0
		if($nova_versao -eq 0) {
			# Atualização carga do PDV
			try {
                $recordsetPdv = $connPdv.Execute("SELECT nomearquivo FROM public.atualizacao ORDER BY id DESC LIMIT 1;")
			    $dia_atuPdv = $recordsetPdv.Fields['nomearquivo'].value.substring(0,2)
			    $mes_atuPdv = $recordsetPdv.Fields['nomearquivo'].value.substring(2,2)
			    $ano_atuPdv = $recordsetPdv.Fields['nomearquivo'].value.substring(4,4)
			    $hora_atuPdv = $recordsetPdv.Fields['nomearquivo'].value.substring(9,5)
			    
			    $pdv_at = $dia_atuPdv + '/' + $mes_atuPdv + '/' + $ano_atuPdv + ' ' + $hora_atuPdv
            } catch {
                $recordsetPdv = $connPdv.Execute("SELECT id, descricao FROM carga.carga_importada ORDER BY id DESC LIMIT 1;")
			    $dia_atuPdv = $recordsetPdv.Fields['descricao'].value.substring(9,2)
			    $mes_atuPdv = $recordsetPdv.Fields['descricao'].value.substring(11,2)
			    $ano_atuPdv = $recordsetPdv.Fields['descricao'].value.substring(13,4)
			    $hora_atuPdv = $recordsetPdv.Fields['descricao'].value.substring(18,5)
			    
			    $pdv_at = $dia_atuPdv + '/' + $mes_atuPdv + '/' + $ano_atuPdv + ' ' + $hora_atuPdv
                $pdv_at_id = $recordsetPdv.Fields['id'].value
            }
		}
	} catch {
		$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + " Ocorreu um erro ao tentar conectar com o PDV $pdv"
        <# $mensagem | Out-File $path_atual\logs.txt -Append
		$Stamp + $_ | Out-File $path_atual\logs.txt -Append #>
        Write-Host $mensagem
	}
	
	# Backup concentrador
	$tam_bkp_diario = -1
	
	try {
		$str = Get-Content "${env:ProgramFiles(x86)}\Processa Sistemas\Backup Mercadologic\shared\config.json";
		$pos_ini_bkp_diario = $str.indexOf("conc_diario");
		$pos_fim_bkp_diario = $str.indexOf(",\n", $pos_ini_bkp_diario);
		$dir_bkp_diario = $str.substring(($pos_ini_bkp_diario + 17), ($pos_fim_bkp_diario - ($pos_ini_bkp_diario + 17) - 1));
		$dir_bkp_diario = $dir_bkp_diario.replace('\\\\', '\');
		$data_atual = (Get-Date).AddDays(-1).toString("dd/MM/yyyy");
		$arquivos = Get-ChildItem "$dir_bkp_diario" | Where-Object { $_.LastWriteTime.Date -eq (get-date -date $data_atual) };
		foreach ($file in $arquivos) { $tam_bkp_diario = [math]::Round($file.Length/1024 ,2) } # Converte para KB
	} catch {
		$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + " Ocorreu um erro ao tentar pegar o tamanho do backup diário do concentrador"
        <# $mensagem | Out-File $path_atual\logs.txt -Append
		$Stamp + $_ | Out-File $path_atual\logs.txt -Append #>
        Write-Host $mensagem
	}

	# Backup lojas
	$tam_bkp_pdv = -1

	try {
		$str = Get-Content "${env:ProgramFiles(x86)}\Processa Sistemas\Backup Mercadologic\shared\config.json";
		$pos_ini_bkp_diario = $str.indexOf('\"pdv\"');
		$pos_fim_bkp_diario = $str.indexOf(",\n", $pos_ini_bkp_diario);
		$dir_bkp_diario = $str.substring(($pos_ini_bkp_diario + 11), ($pos_fim_bkp_diario - ($pos_ini_bkp_diario + 11) - 1));
		$dir_bkp_diario = $dir_bkp_diario.replace('\\\\', '\');
		$data_atual = (Get-Date).AddDays(-1).toString("dd/MM/yyyy");
		$arquivos = Get-ChildItem "$dir_bkp_diario" | Where-Object { ($_.LastWriteTime.Date -eq (get-date -date $data_atual)) -and ($_.Name -LIKE "*PDV$pdv_id*") };
		foreach ($file in $arquivos) { $tam_bkp_pdv = [math]::Round($file.Length/1024 ,2) } # Converte para KB
	} catch {
		$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + " Ocorreu um erro ao tentar pegar o tamanho do backup diário do PDV"
        <# $mensagem | Out-File $path_atual\logs.txt -Append
		$Stamp + $_ | Out-File $path_atual\logs.txt -Append #>
        Write-Host $mensagem
	}

	# Versão do Java
	$ver_jv = 'x.x.xxx'
	
	try {
		$ver_jv = (Get-Command java | Select-Object Version).Version.Major.ToString()
		$ver_jv = $ver_jv + '.' + (Get-Command java | Select-Object Version).Version.Minor.ToString()
		$ver_jv = $ver_jv + '.' + (Get-Command java | Select-Object Version).Version.Build.ToString()
	} catch {
		$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + " Ocorreu um erro ao tentar pegar a versão do postgres"
       <#  $mensagem | Out-File $path_atual\logs.txt -Append
		$Stamp + $_ | Out-File $path_atual\logs.txt -Append #>
        Write-Host $mensagem
	}

	# Versão do Postgres
	$ver_pgs = 'x.x.xxx'
	
	try {
		$ver_pgs = (Get-Command Postgres | Select-Object Version).Version.Major.ToString()
		$ver_pgs = $ver_pgs + '.' + (Get-Command Postgres | Select-Object Version).Version.Minor.ToString()
		$ver_pgs = $ver_pgs + '.' + (Get-Command Postgres | Select-Object Version).Version.Build.ToString()
	} catch {
		$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + " Ocorreu um erro ao tentar pegar a versão do postgres"
       <#  $mensagem | Out-File $path_atual\logs.txt -Append
		$Stamp + $_ | Out-File $path_atual\logs.txt -Append #>
        Write-Host $mensagem
	}

	# Dias sem venda concentrador
	try {
		$recordset_con = $conn_con.Execute("SELECT TO_CHAR(dataabertura, 'yyyy-mm-dd') as dataabertura 
	                                      FROM cupomfiscal 
										 WHERE cancelado = false 
										   AND serieecf = '$pdv'
										 ORDER BY dataabertura DESC LIMIT 1")
		$uv_con = $recordset_con.Fields['dataabertura'].value
	} catch {
		$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + "$pdv : Ocorreu um erro ao tentar pegar a data de abertura do concentrador"
        <# $mensagem | Out-File $path_atual\logs.txt -Append
		$Stamp + $_ | Out-File $path_atual\logs.txt -Append #>
        Write-Host $mensagem
	}

	# Primeiro cupom (primeira venda)
	try {
		$recordset_con = $conn_con.Execute("SELECT TO_CHAR(dataabertura, 'yyyy-mm-dd') as dataabertura FROM cupomfiscal WHERE cancelado = false ORDER BY id ASC LIMIT 1;")
		$pv_con = $recordset_con.Fields['dataabertura'].value
	} catch {
		$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + "$pdv : Ocorreu um erro ao tentar pegar a data de abertura do concentrador"
       <#  $mensagem | Out-File $path_atual\logs.txt -Append
		$Stamp + $_ | Out-File $path_atual\logs.txt -Append #>
        Write-Host $mensagem
	}

	try {
		# Envia os dados para o Manager
		$tudo = "cli=$cli&loj=$loj&pdv=$pdv&pdv_at=$pdv_at&pdv_ve=$pdv_ve&con_ve=$con_ve&ult_ca=$ult_ca&tam_hd=$tam_hd"
		$tudo = $tudo + "&esp_li=$esp_li&ser_ml=$ser_ml&ser_tk=$ser_tk&ser_db=$ser_db&ser_pg=$ser_pg&des_pv=$des_pv"
		$tudo = $tudo + "&ver_ps=$versao_ps1&atu_id=$atu_id&pdv_at_id=$pdv_at_id&bkp_kb_con=$tam_bkp_diario&bkp_kb_pdv=$tam_bkp_pdv"
		$tudo = $tudo + "&ver_jv=$ver_jv&ver_pgs=$ver_pgs&uv_con=$uv_con&pv_con=$pv_con"
		Invoke-WebRequest -Uri "http://manager.processa.info/AcessoDireto/mercadologic.php?$tudo"  -UseBasicParsing -Method 'Get'
	} catch {
		$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")		
        $mensagem = $Stamp + " Ocorreu um erro ao tentar enviar os dados para o manager"
       <#  $mensagem | Out-File $path_atual\logs.txt -Append
		$Stamp + $_ | Out-File $path_atual\logs.txt -Append #>
        Write-Host $mensagem
	}

	# Fecha conexão com Postgres do PDV
	$connPdv.Close();
    
	$recordset.MoveNext()
}

# Fecha conexão com Postgres do Concentrador
$conn_con.Close();

exit