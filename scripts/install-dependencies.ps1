# Install dependencies for both backend and client
# PowerShell-compatible script for installing npm dependencies

Write-Host "🔧 Installing dependencies..." -ForegroundColor Cyan
Write-Host ""

# Store original location
$originalLocation = Get-Location

try {
    # Install client dependencies
    Write-Host "📦 Installing client dependencies..." -ForegroundColor Yellow
    Set-Location client
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to change to client directory"
    }
    
    npm install
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install client dependencies"
    }
    
    Write-Host "✅ Client dependencies installed successfully" -ForegroundColor Green
    Write-Host ""
    
    # Return to root
    Set-Location $originalLocation
    
    # Install backend dependencies
    Write-Host "📦 Installing backend dependencies..." -ForegroundColor Yellow
    npm install
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install backend dependencies"
    }
    
    Write-Host "✅ Backend dependencies installed successfully" -ForegroundColor Green
    Write-Host ""
    
    # Check for vulnerabilities
    Write-Host "🔍 Checking for security vulnerabilities..." -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Backend audit:" -ForegroundColor Yellow
    npm audit --audit-level=moderate
    
    Set-Location client
    Write-Host ""
    Write-Host "Client audit:" -ForegroundColor Yellow
    npm audit --audit-level=moderate
    Set-Location $originalLocation
    
    Write-Host ""
    Write-Host "✅ Installation complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "ℹ️  Note: Some deprecated package warnings are expected." -ForegroundColor Yellow
    Write-Host "   Run 'npm audit fix' in each directory if you want to address vulnerabilities." -ForegroundColor Yellow
    
} catch {
    Write-Host ""
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Set-Location $originalLocation
    exit 1
}

