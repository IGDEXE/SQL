# Fazer Backup do SQL
# Ivo Dias

# Verifica se as pastas estao criadas
function Validar-Pasta {
    param (
        [parameter(position=0,Mandatory=$True)]
        $caminho
    )
    # Verifica se ja existe
    $Existe = Test-Path -Path $caminho
    # Cria a pasta
    if ($Existe -eq $false) {
        try {
            $noReturn = New-Item -ItemType directory -Path $caminho # Cria a pasta
        }
        catch {
            exit
        }
    }
}

# Exibe mensagem de erro
function Mostrar-Erro ($mensagemErro) {
    Limpar-Botoes # Limpa a tela
    $GUI.Text ='DB - ERRO' # Titulo
    $lblCaminho.Visible = $true # Torna visivel
    $lblCaminho.Text = "Favor revisar os dados:"
    $lblRetorno.Text = "$mensagemErro"
    $btnConfirmacao.Visible = $true # Exibe o botao para seguir
}

# Funcao limpar tela
function Limpar-GUI {
    # Limpa as caixas utilizadas
    $txtServidor.Text = ""
    $txtUsuario.Text = ""
    $txtSenha.Text = ""
    # Volta ao padrao inicial
    $lblDiretorio.Visible = $false
    $btnDiretorio.visible = $false
    $lblArquivo.Visible = $false
    $btnArquivo.visible = $false
    $lblCaminho.Visible = $false
    $lblInstancia.Visible = $false
    $cbxInstancia.Visible = $false
    $btnDbDisponivel.Visible = $false
    $btnVerificar.Visible = $false
    $lblDbDisponivel.Visible = $false
    $cbxDbDisponivel.Visible = $false
    $btnSQL.Visible = $false
    $btnConfirmacao.Visible = $false
    $lblRetorno.Text = ""
    $cbxDominio.Text = ""
    $GUI.Text ='DB - Assistente' # Titulo
    # Volta para o tamanho padrao
    $GUI.Size = New-Object System.Drawing.Size(200,300) # Define o tamanho
}

# Funcao limpar tela - Botoes
function Limpar-Botoes {
    # Volta ao padrao inicial
    $lblDiretorio.Visible = $false
    $btnDiretorio.visible = $false
    $lblArquivo.Visible = $false
    $btnArquivo.visible = $false
    $lblCaminho.Visible = $false
    $lblInstancia.Visible = $false
    $cbxInstancia.Visible = $false
    $btnDbDisponivel.Visible = $false
    $btnVerificar.Visible = $false
    $lblDbDisponivel.Visible = $false
    $cbxDbDisponivel.Visible = $false
    $btnSQL.Visible = $false
    $btnConfirmacao.Visible = $false
    $lblRetorno.Text = ""
}

# Funcao para pegar a pasta
Function Get-Folder($servidor) {
    try {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $OpenFileDialog.SelectedPath = "$servidor"
        $OpenFileDialog.ShowDialog() | Out-Null
        $caminhoPasta = $OpenFileDialog.SelectedPath
        return $caminhoPasta
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        Mostrar-Erro $ErrorMessage # Exibe a mensagem de erro
    }
}

# Funcao para pegar arquivo
Function Get-File($initialDirectory) {
    try {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "Backups (*.bak)| *.bak"
        $OpenFileDialog.ShowDialog() | Out-Null
        $OpenFileDialog.filename
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        Mostrar-Erro $ErrorMessage # Exibe a mensagem de erro
    }
}

# Fazer backup no Banco
function SQL-Backup {
    param (
        [parameter(position=0, Mandatory=$True)]
        $Servidor,
        [parameter(position=1, Mandatory=$True)]
        $Usuario,
        [parameter(position=2, Mandatory=$True)]
        $Senha,
        [parameter(position=3, Mandatory=$True)]
        $Caminho
    )
    
    # Escreve a linha de comando
    try {
        osql -s $Servidor -u $Usuario -p $Senha -i comandoSQL -o $Caminho # Faz o procedimento
        #osql -s $Servidor -u $Usuario -p $Senha -q "select name from sys.databases where name not like ('master','model','msdb','tempdb') order by name"
        $retornoProcedimento = "Procedimento concluido com sucesso" # Gera uma mensagem de retorno
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        $retornoProcedimento = "Erro: $ErrorMessage" # Gera uma mensagem de retorno
    }

    return $retornoProcedimento # Retorna a mensagem
}

# Verificar as instancias
function Verificar-Instancias () {
    param (
        [parameter(position=0,Mandatory=$True)]
        $servidor,
        [parameter(position=1,Mandatory=$True)]
        $credencialDominio
    )   
    $servicos = Get-WMIObject Win32_Service -Computer $servidor -Credential $credencialDominio
    $servicos = $servicos | ? DisplayName -like "SQL Server (*)"
    try {
        $instancias = $servicos.Name | ForEach-Object {($_).Replace("MSSQL`$","")}
    }catch{
        # if no instances are found return
        return "Nenhuma instancia foi encontrada"
    }
    return $instancias
}

# Recupera a senha do usuario padrao
function Senha-UsuarioDB {
    $administradorAdSenha = Invoke-command -computer "srsvm030.seniorsolution.com.br" {Get-Content "\\srsvm030.seniorsolution.com.br\Scripts\SRE\Code\DB\Conf\SEC@231020195304.pass" | ConvertTo-SecureString } # Recupera a informacao 
    return $administradorAdSenha
}

# Limpa a checkbox dos Bancos
function Limpar-Bancos {
    
}

# Configuracoes gerais
$PastaPrincipal = "C:\DB" # Define o caminho padrao da pasta de Logs
$pastaTEMP = "$PastaPrincipal\TEMP" # Configura a pasta de temporarios
$identificacao = Get-Date -Format ddMMmmss # Cria um codigo baseado no dia mes minutos segundos
$identificacao += ".txt" # Atribui um tipo ao log
$caminhoLOG = "$pastaTEMP\LOG.$identificacao" # Cria uma bat para fazer o procedimento
$ping = new-object system.net.networkinformation.ping # Para testar se o Servidor esta online
# Validacao dos caminhos
Validar-Pasta $PastaPrincipal
Validar-Pasta $pastaTEMP

# Carrega as credenciais do AD
$administradorDominio = "DB.scripts@seniorsolution.com.br"
$administradorAdSenha = Senha-UsuarioDB
$credencialDominio = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $administradorDominio, $administradorAdSenha

# Formulario principal
Add-Type -assembly System.Windows.Forms # Recebe a biblioteca
Add-Type -AssemblyName PresentationFramework # Recebe a biblioteca de mensagens
$GUI = New-Object System.Windows.Forms.Form # Cria o formulario principal
$GUI.Text ='DB - Assistente' # Titulo
$GUI.AutoSize = $true # Configura para aumentar caso necessario
$GUI.StartPosition = 'CenterScreen' # Inicializa no centro da tela

# Dominio
$lblDominio = New-Object System.Windows.Forms.Label # Cria a label
$lblDominio.Text = "Dominio:" # Define um texto para ela
$lblDominio.Location  = New-Object System.Drawing.Point(0,10) # Define em qual coordenada da tela vai ser desenhado
$lblDominio.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblDominio) # Adiciona ao formulario principal
$cbxDominio = New-Object System.Windows.Forms.ComboBox # Cria uma Combobox
$cbxDominio.Width = 200 # Define um tamanho
$cbxDominio.Location  = New-Object System.Drawing.Point(100,10) # Define a localizacao
$cbxDominio.Items.Add("SeniorSolution") # Exemplo de opcoes 
$cbxDominio.Items.Add("ATT") # Exemplo de opcoes
$cbxDominio.Items.Add("Drive") # Exemplo de opcoes
$GUI.Controls.Add($cbxDominio) # Adiciona ao formulario principal

# Servidor
$lblServidor = New-Object System.Windows.Forms.Label # Cria a label
$lblServidor.Text = "Servidor de Banco:" # Define um texto para ela
$lblServidor.Location  = New-Object System.Drawing.Point(0,30) # Define em qual coordenada da tela vai ser desenhado
$lblServidor.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblServidor) # Adiciona ao formulario principal
$txtServidor = New-Object System.Windows.Forms.TextBox # Cria a caixa de texto
$txtServidor.Width = 200 # Configura o tamanho
$txtServidor.Location  = New-Object System.Drawing.Point(100,30) # Define em qual coordenada da tela vai ser desenhado
$GUI.Controls.Add($txtServidor) # Adiciona ao formulario principal

# Usuario
$lblUsuario = New-Object System.Windows.Forms.Label # Cria a label
$lblUsuario.Text = "Usuario do banco:" # Define um texto para ela
$lblUsuario.Location  = New-Object System.Drawing.Point(0,50) # Define em qual coordenada da tela vai ser desenhado
$lblUsuario.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblUsuario) # Adiciona ao formulario principal
$txtUsuario = New-Object System.Windows.Forms.TextBox # Cria a caixa de texto
$txtUsuario.Width = 200 # Configura o tamanho
$txtUsuario.Location  = New-Object System.Drawing.Point(100,50) # Define em qual coordenada da tela vai ser desenhado
$GUI.Controls.Add($txtUsuario) # Adiciona ao formulario principal

# Senha
$lblSenha = New-Object System.Windows.Forms.Label # Cria a label
$lblSenha.Text = "Senha do banco:" # Define um texto para ela
$lblSenha.Location  = New-Object System.Drawing.Point(0,70) # Define em qual coordenada da tela vai ser desenhado
$lblSenha.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblSenha) # Adiciona ao formulario principal
$txtSenha = New-Object Windows.Forms.MaskedTextBox # Cria a caixa de texto
$txtSenha.PasswordChar = '*' # Coloca um caractere especial para a senha
$txtSenha.Width = 200 # Configura o tamanho
$txtSenha.Location  = New-Object System.Drawing.Point(100,70) # Define em qual coordenada da tela vai ser desenhado
$GUI.Controls.Add($txtSenha) # Adiciona ao formulario principal

# Diretorio
$lblDiretorio = New-Object System.Windows.Forms.Label # Cria a label
$lblDiretorio.Text = "Diretorio Backup:" # Define um texto para ela
$lblDiretorio.Location  = New-Object System.Drawing.Point(0,110) # Define em qual coordenada da tela vai ser desenhado
$lblDiretorio.AutoSize = $true # Configura tamanho automatico
$lblDiretorio.Visible = $false # Deixa invisivel na inicializacao
$GUI.Controls.Add($lblDiretorio) # Adiciona ao formulario principal
# Botao para escolher o arquivo
$btnDiretorio = New-Object System.Windows.Forms.Button # Cria um botao
$btnDiretorio.Location = New-Object System.Drawing.Size(100,110) # Define em qual coordenada da tela vai ser desenhado
$btnDiretorio.Size = New-Object System.Drawing.Size(200,18) # Define o tamanho
$btnDiretorio.visible = $false # Deixa invisivel na inicializacao
$btnDiretorio.Text = "Definir pasta" # Define o texto
$GUI.Controls.Add($btnDiretorio) # Adiciona ao formulario principal

# Arquivo
$lblArquivo = New-Object System.Windows.Forms.Label # Cria a label
$lblArquivo.Text = "Arquivo Restore:" # Define um texto para ela
$lblArquivo.Location  = New-Object System.Drawing.Point(0,110) # Define em qual coordenada da tela vai ser desenhado
$lblArquivo.AutoSize = $true # Configura tamanho automatico
$lblArquivo.Visible = $false # Deixa invisivel na inicializacao
$GUI.Controls.Add($lblArquivo) # Adiciona ao formulario principal
# Botao para escolher o arquivo
$btnArquivo = New-Object System.Windows.Forms.Button # Cria um botao
$btnArquivo.Location = New-Object System.Drawing.Size(100,110) # Define em qual coordenada da tela vai ser desenhado
$btnArquivo.Size = New-Object System.Drawing.Size(200,18) # Define o tamanho
$btnArquivo.visible = $false # Deixa invisivel na inicializacao
$btnArquivo.Text = "Escolher arquivo" # Define o texto
$GUI.Controls.Add($btnArquivo) # Adiciona ao formulario principal

# Botao para verificar as instancias
$btnVerificar = New-Object System.Windows.Forms.Button # Cria um botao
$btnVerificar.Location = New-Object System.Drawing.Size(5,170) # Define em qual coordenada da tela vai ser desenhado
$btnVerificar.Visible = $false # Deixa invisivel na inicializacao
$btnVerificar.Size = New-Object System.Drawing.Size(300,25) # Define o tamanho
$btnVerificar.Text = "Verificar Instancias" # Define o texto
$GUI.Controls.Add($btnVerificar) # Adiciona ao formulario principal

# Botao para fazer o procedimento
$btnSQL = New-Object System.Windows.Forms.Button # Cria um botao
$btnSQL.Location = New-Object System.Drawing.Size(5,300) # Define em qual coordenada da tela vai ser desenhado
$btnSQL.Visible = $false # Deixa invisivel na inicializacao
$btnSQL.Size = New-Object System.Drawing.Size(300,25) # Define o tamanho
$btnSQL.Text = "Fazer" # Define o texto
$GUI.Controls.Add($btnSQL) # Adiciona ao formulario principal

# Procedimento
$lblProcedimento = New-Object System.Windows.Forms.Label # Cria a label
$lblProcedimento.Text = "Procedimento:" # Define um texto para ela
$lblProcedimento.Location  = New-Object System.Drawing.Point(0,90) # Define em qual coordenada da tela vai ser desenhado
$lblProcedimento.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblProcedimento) # Adiciona ao formulario principal
# Botao para escolher o procedimento
# Backup:
$btnBackup = New-Object System.Windows.Forms.Button # Cria um botao
$btnBackup.Location = New-Object System.Drawing.Size(100,90) # Define em qual coordenada da tela vai ser desenhado
$btnBackup.Size = New-Object System.Drawing.Size(100,18) # Define o tamanho
$btnBackup.Text = "Backup" # Define o texto
$GUI.Controls.Add($btnBackup) # Adiciona ao formulario principal
# Restore:
$btnRestore = New-Object System.Windows.Forms.Button # Cria um botao
$btnRestore.Location = New-Object System.Drawing.Size(200,90) # Define em qual coordenada da tela vai ser desenhado
$btnRestore.Size = New-Object System.Drawing.Size(100,18) # Define o tamanho
$btnRestore.Text = "Restore" # Define o texto
$GUI.Controls.Add($btnRestore) # Adiciona ao formulario principal

# Label de exibicao do caminho
$lblCaminho = New-Object System.Windows.Forms.Label # Cria a label
$lblCaminho.Text = "Caminho selecionado: " # Coloca um texto em branco
$lblCaminho.Visible = $false # Deixa invisivel na inicializacao
$lblCaminho.Location  = New-Object System.Drawing.Point(0,140) # Define em qual coordenada da tela vai ser desenhado
$lblCaminho.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblCaminho) # Adiciona ao formulario principal

# Label para receber o retorno do procedimento
$lblRetorno = New-Object System.Windows.Forms.Label # Cria a label
$lblRetorno.Text = "" # Coloca um texto em branco
$lblRetorno.Location  = New-Object System.Drawing.Point(0,155) # Define em qual coordenada da tela vai ser desenhado
$lblRetorno.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblRetorno) # Adiciona ao formulario principal

# Label para salvar dados
$lblProcesso = New-Object System.Windows.Forms.Label # Cria a label
$lblProcesso.Text = "" # Coloca um texto em branco
$lblProcesso.Visible = $false # Deixa invisivel na inicializacao
$lblProcesso.Location  = New-Object System.Drawing.Point(0,155) # Define em qual coordenada da tela vai ser desenhado
$lblProcesso.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblProcesso) # Adiciona ao formulario principal
$lblCaminhoProcesso = New-Object System.Windows.Forms.Label # Cria a label
$lblCaminhoProcesso.Text = "" # Coloca um texto em branco
$lblCaminhoProcesso.Visible = $false # Deixa invisivel na inicializacao
$lblCaminhoProcesso.Location  = New-Object System.Drawing.Point(0,155) # Define em qual coordenada da tela vai ser desenhado
$lblCaminhoProcesso.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblCaminhoProcesso) # Adiciona ao formulario principal

# Instancias
$lblInstancia = New-Object System.Windows.Forms.Label # Cria a label
$lblInstancia.Text = "Instancias:" # Define um texto para ela
$lblInstancia.Visible = $false # Deixa invisivel na inicializacao
$lblInstancia.Location  = New-Object System.Drawing.Point(0,200) # Define em qual coordenada da tela vai ser desenhado
$lblInstancia.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblInstancia) # Adiciona ao formulario principal
$cbxInstancia = New-Object System.Windows.Forms.ComboBox # Cria uma Combobox
$cbxInstancia.Width = 200 # Define um tamanho
$cbxInstancia.Visible = $false # Deixa invisivel na inicializacao
$cbxInstancia.Location  = New-Object System.Drawing.Point(100,200) # Define a localizacao
$GUI.Controls.Add($cbxInstancia) # Adiciona ao formulario principal

# Botao para verificar os bancos disponiveis
$btnDbDisponivel = New-Object System.Windows.Forms.Button # Cria um botao
$btnDbDisponivel.Location = New-Object System.Drawing.Size(5,230) # Define em qual coordenada da tela vai ser desenhado
$btnDbDisponivel.Visible = $false # Deixa invisivel na inicializacao
$btnDbDisponivel.Size = New-Object System.Drawing.Size(300,25) # Define o tamanho
$btnDbDisponivel.Text = "Verificar Bancos" # Define o texto
$GUI.Controls.Add($btnDbDisponivel) # Adiciona ao formulario principal

# DBs disponiveis
$lblDbDisponivel = New-Object System.Windows.Forms.Label # Cria a label
$lblDbDisponivel.Text = "DBs disponiveis:" # Define um texto para ela
$lblDbDisponivel.Visible = $false # Deixa invisivel na inicializacao
$lblDbDisponivel.Location  = New-Object System.Drawing.Point(0,265) # Define em qual coordenada da tela vai ser desenhado
$lblDbDisponivel.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblDbDisponivel) # Adiciona ao formulario principal
$cbxDbDisponivel = New-Object System.Windows.Forms.ComboBox # Cria uma Combobox
$cbxDbDisponivel.Width = 200 # Define um tamanho
$cbxDbDisponivel.Visible = $false # Deixa invisivel na inicializacao
$cbxDbDisponivel.Location  = New-Object System.Drawing.Point(100,265) # Define a localizacao
$GUI.Controls.Add($cbxDbDisponivel) # Adiciona ao formulario principal

# Botao para seguir
$btnConfirmacao = New-Object System.Windows.Forms.Button # Cria um botao
$btnConfirmacao.Location = New-Object System.Drawing.Size(5,170) # Define em qual coordenada da tela vai ser desenhado
$btnConfirmacao.Visible = $false # Deixa invisivel na inicializacao
$btnConfirmacao.Size = New-Object System.Drawing.Size(300,25) # Define o tamanho
$btnConfirmacao.Text = "OK" # Define o texto
$GUI.Controls.Add($btnConfirmacao) # Adiciona ao formulario principal

# Evento do Botao Arquivo
$btnRestore.Add_Click({
    Limpar-Botoes # Deixa a tela apenas com os campos certos
    $GUI.Text ='DB - Restaurar Backup' # Titulo
    $lblDiretorio.Visible = $false # Deixa invisivel
    $btnDiretorio.visible = $false # Deixa invisivel
    $lblArquivo.Visible = $true # Deixa visivel
    $btnArquivo.visible = $true # Deixa visivel
    $lblProcesso.Text = "Restore" # Informa o tipo do procedimento
})

# Evento do Botao Backup
$btnBackup.Add_Click({
    Limpar-Botoes # Deixa a tela apenas com os campos certos
    $GUI.Text ='DB - Fazer Backup' # Titulo
    $lblArquivo.Visible = $false # Deixa invisivel
    $btnArquivo.visible = $false # Deixa invisivel
    $lblDiretorio.Visible = $true # Deixa visivel
    $btnDiretorio.visible = $true # Deixa visivel
    $lblProcesso.Text = "Backup" # Informa o tipo do procedimento
})

# Evento do Botao Diretorio
$btnDiretorio.Add_Click({
    # Verifica dominio selecionado
    $opcao = $cbxDominio.selectedItem
    if ($opcao -eq "SeniorSolution") { $dominio = ".seniorsolution.com.br" }
    if ($opcao -eq "ATT") { $dominio = ".att.com.br" }
    if ($opcao -eq "Drive") { $dominio = ".drive.com.br" }
    $servidor = "\\" + $txtServidor.Text + $dominio # Configura o nome do servidor
    $caminhoPasta = Get-Folder $servidor # Recebe a pasta onde o backup precisa ser feito
    $lblCaminho.visible = $true # Deixa visivel
    $lblRetorno.Text = $caminhoPasta # Exibe o caminho selecionado
    $btnVerificar.Visible = $true # Torna visivel
    $lblCaminhoProcesso.Text = $caminhoPasta # Retorna o caminho
})

# Evento do Botao Restore
$btnArquivo.Add_Click({
    $caminhoPasta = Get-File # Recebe a pasta onde o backup precisa ser feito
    $lblCaminho.visible = $true # Deixa visivel
    $lblRetorno.Text = $caminhoPasta # Exibe o caminho selecionado
    $btnVerificar.Visible = $true # Torna visivel
    $lblCaminhoProcesso.Text = $caminhoPasta # Retorna o caminho
})

# Evento do Botao que verifica as instancias
$btnVerificar.Add_Click({
    try {
        # Limpa as combobox
        $cbxInstancia.Items.Clear()
        $cbxDbDisponivel.Items.Clear()
        # Verifica dominio selecionado
        $opcao = $cbxDominio.selectedItem
        if ($opcao -eq "SeniorSolution") { $dominio = ".seniorsolution.com.br" }
        if ($opcao -eq "ATT") { $dominio = ".att.com.br" }
        if ($opcao -eq "Drive") { $dominio = ".drive.com.br" }
        $servidor = $txtServidor.Text + $dominio # Configura o nome do servidor
        $Online = $ping.send("$servidor")
        $Online = $Online.Status
        if ($Online -eq "Success") {
            $instancias = Verificar-Instancias $servidor $credencialDominio # Verifica as instancias
            # Atribui as instancias encontradas na opcao
            foreach ($instancia in $instancias) {
                $cbxInstancia.Items.Add($instancia) # Adiciona como opcao cada um dos setores
            }
            $lblInstancia.Visible = $true # Torna visivel
            $cbxInstancia.Visible = $true # Torna visivel
            $btnDbDisponivel.Visible = $true # Torna visivel
        } else {
            Limpar-GUI # Volta a configuracao inicial
            $lblRetorno.Text = "O servidor informado nao esta disponivel no momento"
            $btnConfirmacao.Visible = $true # Exibe o botao para seguir
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        Mostrar-Erro $ErrorMessage # Exibe a mensagem de erro
    }
})

# Evento do Botao que verifica os bancos
$btnDbDisponivel.Add_Click({
    try {
        # Limpa as combobox
        $cbxDbDisponivel.Items.Clear()
        # Verifica dominio selecionado
        $opcao = $cbxDominio.selectedItem
        if ($opcao -eq "SeniorSolution") { $dominio = ".seniorsolution.com.br" }
        if ($opcao -eq "ATT") { $dominio = ".att.com.br" }
        if ($opcao -eq "Drive") { $dominio = ".drive.com.br" }
        $servidor = $txtServidor.Text + $dominio # Configura o nome do servidor
        # Verifica a instancia
        $instancia = $cbxInstancia.selectedItem
        # Recebe o usuario e a senha
        $Usuario = $txtUsuario.Text
        $Senha = $txtSenha.Text
        # Recebe os bancos disponiveis
        if ($instancia -eq "MSSQLSERVER") {
            $DBs = sqlcmd -S $servidor -U $Usuario -P $Senha -Q "select name from sys.databases where name not in ('master','model','msdb','tempdb') order by name"    
        } else {
            $DBs = sqlcmd -S "$servidor\$instancia" -U $Usuario -P $Senha -Q "select name from sys.databases where name not in ('master','model','msdb','tempdb') order by name"
        }
        # Remove os textos desnecessarios
        $DBs = $DBs | Where-Object { $_ -ne "" } | ForEach-Object { $_.Replace(" ","") }
        $DBs = $DBs | Where-Object { $_ -ne "" } | ForEach-Object { $_.Replace("--","") }
        $DBs = $DBs | Where-Object { $_ -ne "" } | ForEach-Object { $_.Replace("name","") }
        $DBs = $DBs | Where-Object { $_ -ne "" } | ForEach-Object { $_.Replace("(637rowsaffected)","") }
        $DBs = $DBs | Where-Object { $_ -ne "" } | ForEach-Object { $_.Replace(" ","") }
        # Adiciona os bancos como opcoes
        foreach ($DB in $DBs) {
            $cbxDbDisponivel.Items.Add($DB) # Adiciona como opcao cada um dos setores
        }
        $lblDbDisponivel.Visible = $true # Torna visivel
        $cbxDbDisponivel.Visible = $true # Torna visivel
        $btnSQL.Visible = $true # Torna visivel
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        Mostrar-Erro $ErrorMessage # Exibe a mensagem de erro
    }
})

# Evento do Botao que faz o procedimento com SQL
$btnSQL.Add_Click({
    try {
        # Recebe os dados
        $procedimento = $lblProcesso.Text # Tipo de procedimento
        $caminhoProcedimento = $lblCaminhoProcesso.Text # Caminho da pasta ou do arquivo
        # Verifica dominio selecionado
        $opcao = $cbxDominio.selectedItem
        if ($opcao -eq "SeniorSolution") { $dominio = ".seniorsolution.com.br" }
        if ($opcao -eq "ATT") { $dominio = ".att.com.br" }
        if ($opcao -eq "Drive") { $dominio = ".drive.com.br" }
        $servidor = $txtServidor.Text + $dominio # Configura o nome do servidor
        # Verifica a instancia
        $instancia = $cbxInstancia.selectedItem
        # Recebe o usuario e a senha
        $Usuario = $txtUsuario.Text
        $Senha = $txtSenha.Text
        # Recebe o Banco
        $nomeBanco = $cbxDbDisponivel.selectedItem
        # Gera o arquivo de LOG
        $hash = Get-Date -Format yyyyMMddHHmm
        $caminhoLOG = "$pastaTEMP\LOG.$hash.out" # Cria uma bat para fazer o procedimento
        # Configura a tela
        Limpar-GUI # Limpa a tela para mostrar apenas o Log
        $lblRetorno.Text = "Aguarde, estamos fazendo os procedimentos necessarios"
        # Verifica o procedimento:
        # Backup
        if ($procedimento -eq "Backup") {
            $nomeBackup = "BKP_$nomeBanco.$hash.bak"
            $caminhoProcedimento = "$caminhoProcedimento\$nomeBackup"
            # Configura a Query
            $query = "BACKUP DATABASE $nomeBanco TO DISK = #$caminhoProcedimento#"
            $query = $query -replace "#", "'"
            # Recebe os bancos disponiveis
            if ($instancia -eq "MSSQLSERVER") {
                $log = sqlcmd -S $servidor -U $Usuario -P $Senha -Q $query
            } else {
                $log = sqlcmd -S "$servidor\$instancia" -U $Usuario -P $Senha -Q $query
            }
        } 
        # Restore
        if ($procedimento -eq "Restore") {
            # Configura a Query
            $query = "RESTORE DATABASE $nomeBanco FROM DISK = #$caminhoProcedimento#"
            $query = $query -replace "#", "'"
            # Recebe os bancos disponiveis
            if ($instancia -eq "MSSQLSERVER") {
                $log = sqlcmd -S $servidor -U $Usuario -P $Senha -Q $query
            } else {
                $log = sqlcmd -S "$servidor\$instancia" -U $Usuario -P $Senha -Q $query
            }
        }
        # Cria LOGs
        Add-Content -Path $caminhoLOG -Value $log
        # Finaliza
        $lblCaminho.Visible = $true # Torna visivel
        $lblCaminho.Text = "Procedimento concluido:"
        $lblRetorno.Text = "Para saber mais: $caminhoLOG"
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        Mostrar-Erro $ErrorMessage # Exibe a mensagem de erro
    }
    $btnConfirmacao.Visible = $true # Exibe o botao para seguir
})

# Evento do Botao para seguir
$btnConfirmacao.Add_Click({
    Limpar-GUI # Limpa
})

# Inicia o formulario
$GUI.ShowDialog() # Desenha na tela todos os componentes adicionados ao formulario