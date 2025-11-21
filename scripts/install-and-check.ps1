# Install dependencies and check for errors
# This script will install dependencies and then check for TypeScript errors

Write-Host "🔧 Installing dependencies and checking for errors..." -ForegroundColor Cyan
Write-Host ""

# Check if node_modules exists
if (-not (Test-Path "client\node_modules")) {
    Write-Host "📦 Installing client dependencies..." -ForegroundColor Yellow
    Set-Location client
    try {
        npm install
        Write-Host "✅ Client dependencies installed" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to install client dependencies" -ForegroundColor Red
        Set-Location ..
        exit 1
    }
    Set-Location ..
} else {
    Write-Host "✅ Client node_modules already exists" -ForegroundColor Green
}

# Check if backend node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing backend dependencies..." -ForegroundColor Yellow
    try {
        npm install
        Write-Host "✅ Backend dependencies installed" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to install backend dependencies" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Backend node_modules already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "🔍 Running full check..." -ForegroundColor Cyan
Write-Host ""

# Run full check
if (Test-Path "scripts\full-check.ps1") {
    .\scripts\full-check.ps1
} else {
    Write-Host "Running manual checks..." -ForegroundColor Yellow
    
    # Prisma validate
    Write-Host "1️⃣  Validating Prisma Schema..." -ForegroundColor Yellow
    npx prisma validate
    
    # Backend TypeScript
    Write-Host "2️⃣  Checking Backend TypeScript..." -ForegroundColor Yellow
    npx tsc --noEmit
    
    # Frontend TypeScript
    Write-Host "3️⃣  Checking Frontend TypeScript..." -ForegroundColor Yellow
    Set-Location client
    npx vue-tsc --noEmit
    Set-Location ..
}

Write-Host ""
Write-Host "✅ Done!" -ForegroundColor Green

