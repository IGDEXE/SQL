# Fazer Backup do SQL
# Ivo Dias

# Formulario principal
Add-Type -assembly System.Windows.Forms # Recebe a biblioteca
$GUI = New-Object System.Windows.Forms.Form # Cria o formulario principal
$GUI.Text ='DB - Restaurar Backup' # Titulo
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

# Procedimento
$lblProcedimento = New-Object System.Windows.Forms.Label # Cria a label
$lblProcedimento.Text = "Procedimento:" # Define um texto para ela
$lblProcedimento.Location  = New-Object System.Drawing.Point(0,90) # Define em qual coordenada da tela vai ser desenhado
$lblProcedimento.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblProcedimento) # Adiciona ao formulario principal
$cbxProcedimento = New-Object System.Windows.Forms.ComboBox # Cria uma Combobox
$cbxProcedimento.Width = 200 # Define um tamanho
$cbxProcedimento.Location  = New-Object System.Drawing.Point(100,90) # Define a localizacao
$cbxProcedimento.Items.Add("Backup") # Exemplo de opcoes 
$cbxProcedimento.Items.Add("Restore") # Exemplo de opcoes
$GUI.Controls.Add($cbxProcedimento) # Adiciona ao formulario principal

# Diretorio
$lblDiretorio = New-Object System.Windows.Forms.Label # Cria a label
$lblDiretorio.Text = "Diretorio:" # Define um texto para ela
$lblDiretorio.Location  = New-Object System.Drawing.Point(0,110) # Define em qual coordenada da tela vai ser desenhado
$lblDiretorio.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblDiretorio) # Adiciona ao formulario principal

# Funcao para pegar o caminho do arquivo
Function Get-Folder($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFileDialog.rootfolder = "MyComputer"
    $OpenFileDialog.ShowDialog() | Out-Null
    $caminhoPasta = $OpenFileDialog.SelectedPath
    return $caminhoPasta
}

# Botao para escolher o arquivo
$btnDiretorio = New-Object System.Windows.Forms.Button # Cria um botao
$btnDiretorio.Location = New-Object System.Drawing.Size(100,110) # Define em qual coordenada da tela vai ser desenhado
$btnDiretorio.Size = New-Object System.Drawing.Size(200,18) # Define o tamanho
$btnDiretorio.Text = "Definir pasta" # Define o texto
$GUI.Controls.Add($btnDiretorio) # Adiciona ao formulario principal

# Botao para fazer o procedimento
$btnSQL = New-Object System.Windows.Forms.Button # Cria um botao
$btnSQL.Location = New-Object System.Drawing.Size(5,150) # Define em qual coordenada da tela vai ser desenhado
$btnSQL.Size = New-Object System.Drawing.Size(300,25) # Define o tamanho
$btnSQL.Text = "Fazer" # Define o texto
$GUI.Controls.Add($btnSQL) # Adiciona ao formulario principal

# Label para receber o retorno do procedimento
$lblResposta = New-Object System.Windows.Forms.Label # Cria a label
$lblResposta.Text = "" # Coloca um texto em branco
$lblResposta.Location  = New-Object System.Drawing.Point(0,150) # Define em qual coordenada da tela vai ser desenhado
$lblResposta.AutoSize = $true # Configura tamanho automatico
$GUI.Controls.Add($lblResposta) # Adiciona ao formulario principal

# Evento do Botao Diretorio
$btnDiretorio.Add_Click({
    $caminhoPasta = Get-Folder # Recebe a pasta onde o backup precisa ser feito
    $lblResposta.Text = $caminhoPasta
})

# Inicia o formulario
$GUI.ShowDialog() # Desenha na tela todos os componentes adicionados ao formulario