# Gerar uma senha como arquivo Hash
# Ivo Dias

# Faz o procedimento
Clear-Host
Write-Host "Converter senha em arquivo seguro"
try {
    # Recebe os dados do cliente
    $caminhoArquivo = Read-Host "Informe o caminho do arquivo"
    $hash = Get-Date -Format SEC@ddMMyyyyssmm
    # Gera a chave
    $KeyFile = "$caminhoArquivo\$hash.key"
    $Key = New-Object Byte[] 32   # You can use 16 (128-bit), 24 (192-bit), or 32 (256-bit) for AES
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
    $Key | Out-File $KeyFile
    # Gera a senha
    Read-Host "Informe sua senha" -AsSecureString | ConvertFrom-SecureString -key $Key | Out-File "$caminhoArquivo\$hash.pass" # Gera a senha
    Write-Host "Arquivos gerados em: $caminhoArquivo"
}
catch {
    $ErrorMessage = $_.Exception.Message # Recebe a mensagem de erro
    Write-Host "Erro: $ErrorMessage"
}
Pause