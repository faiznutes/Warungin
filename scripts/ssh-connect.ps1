# PowerShell script untuk SSH dengan password
$hostname = "192.168.0.101"
$username = "warungin"
$password = "123"

# Convert password to SecureString
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Try SSH using OpenSSH (if available)
Write-Host "Attempting SSH connection to $username@$hostname..."

# Use ssh.exe directly with password via stdin
$password | & "C:\Windows\System32\OpenSSH\ssh.exe" -o StrictHostKeyChecking=no "$username@$hostname" "echo 'Connected successfully'; hostname; whoami"

# Alternative: Use plink if PuTTY is installed
if (-not $LASTEXITCODE -eq 0) {
    Write-Host "Trying with plink..."
    $plinkPath = "C:\Program Files\PuTTY\plink.exe"
    if (Test-Path $plinkPath) {
        & $plinkPath -ssh "$username@$hostname" -pw $password "echo 'Connected successfully'; hostname; whoami"
    } else {
        Write-Host "Please run manually in Git Bash:"
        Write-Host "ssh warungin@192.168.0.101"
        Write-Host "Password: 123"
    }
}

