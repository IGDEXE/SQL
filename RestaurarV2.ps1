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
    $lblRetorno.Text = ""
}

# Funcao para pegar a pasta
Function Get-Folder {
    param (
        [parameter(position=0, Mandatory=$True)]
        $servidor
    )
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    #$OpenFileDialog.rootfolder = "MyComputer"
    $OpenFileDialog.SelectedPath = "$servidor"
    $OpenFileDialog.ShowDialog() | Out-Null
    $caminhoPasta = $OpenFileDialog.SelectedPath
    return $caminhoPasta
}

# Funcao para pegar arquivo
Function Get-File($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Inputs (*.inp)| *.inp"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
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

# Configuracoes gerais
$PastaPrincipal = "C:\DB" # Define o caminho padrao da pasta de Logs
$pastaTEMP = "$PastaPrincipal\TEMP" # Configura a pasta de temporarios
$identificacao = Get-Date -Format ddMMmmss # Cria um codigo baseado no dia mes minutos segundos
$identificacao += ".txt" # Atribui um tipo ao log
# Validacao dos caminhos
Validar-Pasta $PastaPrincipal
Validar-Pasta $pastaTEMP

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

# Botao para verificar os bancos
$btnVerificar = New-Object System.Windows.Forms.Button # Cria um botao
$btnVerificar.Location = New-Object System.Drawing.Size(5,190) # Define em qual coordenada da tela vai ser desenhado
$btnVerificar.Size = New-Object System.Drawing.Size(300,25) # Define o tamanho
$btnVerificar.Text = "Verificar Dados" # Define o texto
$GUI.Controls.Add($btnVerificar) # Adiciona ao formulario principal

# Botao para fazer o procedimento
$btnSQL = New-Object System.Windows.Forms.Button # Cria um botao
$btnSQL.Location = New-Object System.Drawing.Size(5,215) # Define em qual coordenada da tela vai ser desenhado
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

# Evento do Botao Arquivo
$btnRestore.Add_Click({
    $GUI.Text ='DB - Restaurar Backup' # Titulo
    $lblDiretorio.Visible = $false # Deixa invisivel
    $btnDiretorio.visible = $false # Deixa invisivel
    $lblArquivo.Visible = $true # Deixa visivel
    $btnArquivo.visible = $true # Deixa visivel
})

# Evento do Botao Backup
$btnBackup.Add_Click({
    $GUI.Text ='DB - Fazer Backup' # Titulo    
    $lblArquivo.Visible = $false # Deixa invisivel
    $btnArquivo.visible = $false # Deixa invisivel
    $lblDiretorio.Visible = $true # Deixa visivel
    $btnDiretorio.visible = $true # Deixa visivel
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
})

# Evento do Botao Restore
$btnArquivo.Add_Click({
    $caminhoPasta = Get-File # Recebe a pasta onde o backup precisa ser feito
    $lblCaminho.visible = $true # Deixa visivel
    $lblRetorno.Text = $caminhoPasta # Exibe o caminho selecionado
})

# Evento do Botao que faz o procedimento com SQL
$btnVerificar.Add_Click({
    $lblRetorno.Text = "Aguarde, estamos fazendo os procedimentos necessarios"
    Limpar-GUI # Volta a configuracao inicial
})

# Evento do Botao que faz o procedimento com SQL
$btnSQL.Add_Click({
    $lblRetorno.Text = "Aguarde, estamos fazendo os procedimentos necessarios"
    Limpar-GUI # Volta a configuracao inicial
})

# Inicia o formulario
$GUI.ShowDialog() # Desenha na tela todos os componentes adicionados ao formulario