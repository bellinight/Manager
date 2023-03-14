# Manager Processa Sistemas
# Sistema de Captura de dados para controle de PDV´s
# Automatização e Instalação Manager

O Manager é um sistema de captura de dados executado em Powershell com envio dos dados para servidor da Processa por meio de link HTTP. Estes dados coletados são repassados para uma dashboard para acompanhamento do setor de Suporte da Processa Sistemas.

# Desafios da automatização:

1 - Envio em tempo real (Servidor de dados atualizando por Min) <p>
2 - Instalação fácil a nivel de usuario<p>
3 - Estabilidade no envio, evitar paradas no agendamento manual<p>
4 - Organização de scripts, adicionar subpastas para facilitar a atualização e desenvolvimento.<p>
5 - Opção de fácil atualização OFFLINE (Invoke e capturado como virus por muitos AV(KPSk))<p>

# Instalação do sistema

1 - Efetue o download do Release<p>
2 - Siga os passos solicitados pelo instalador<p>
3 - Instale as dependências apresentadas pelo instalador<p>
4 - Acesse o Portal do Manager http://manager.processa.info/<p>
5 - Efetue Login<p>
6 - Confira se a loja atualizada já tem o S na frente da versão do PS1, isso indica a instalação do serviço.<p>
7 - Acompanhe o envio de dados verificando a coluna Último Envio dentro das informações da Loja em questão.<p>
8 - Para conferências extras, acesse o agendador de tarefas e busque pela Task (RestartManager), execute e verifique se algum erro é apresentado. Observe a pasta LOG dentro da aplicação Mercadologic ela contém logs do reinício do serviço.<p>
Verifique o serviço (Processa Manager) instalado e efetue um reinicio para verificação de erros.<p>

# Erros comuns

1 - Dados do cliente, serviços ou servidor na pasta (Mercadologic\Manager\files) com id´s e descrições erradas.<p>
2 - Versão do powershell muito antiga, confira a versão caso o instalador não tenha atualizado.<p>
3 - Variáveis de ambiente para Postgresql ausentes.<p>
4 - Erros de script - Efetue a execução do script PS1 diretamente no ISE do Powershell para verificação dos erros.<p>
