# Full Check Script for Warungin POS System (PowerShell)
# Checks TypeScript, Linting, Prisma, and Tests

$ErrorActionPreference = "Stop"

Write-Host "🔍 Starting Full Check for Warungin POS System..." -ForegroundColor Cyan
Write-Host ""

$skipTests = $args -contains "--skip-tests"

# 1. Prisma Validation
Write-Host "1️⃣  Validating Prisma Schema..." -ForegroundColor Yellow
try {
    npx prisma validate 2>&1 | Out-Null
    Write-Host "✅ Prisma Schema OK" -ForegroundColor Green
} catch {
    Write-Host "❌ Prisma schema errors found!" -ForegroundColor Red
    npx prisma validate
    exit 1
}

# 2. Prisma Generate
Write-Host ""
Write-Host "2️⃣  Generating Prisma Client..." -ForegroundColor Yellow
try {
    npm run prisma:generate 2>&1 | Out-Null
    Write-Host "✅ Prisma Client Generated" -ForegroundColor Green
} catch {
    Write-Host "❌ Prisma generate errors found!" -ForegroundColor Red
    npm run prisma:generate
    exit 1
}

# 3. Backend TypeScript Check
Write-Host ""
Write-Host "3️⃣  Checking Backend TypeScript..." -ForegroundColor Yellow
try {
    npx tsc --noEmit 2>&1 | Out-Null
    Write-Host "✅ Backend TypeScript OK" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend TypeScript errors found!" -ForegroundColor Red
    npx tsc --noEmit
    exit 1
}

# 4. Frontend TypeScript Check
Write-Host ""
Write-Host "4️⃣  Checking Frontend TypeScript..." -ForegroundColor Yellow
Set-Location client
try {
    npx vue-tsc --noEmit 2>&1 | Out-Null
    Write-Host "✅ Frontend TypeScript OK" -ForegroundColor Green
    Set-Location ..
} catch {
    Set-Location ..
    Write-Host "❌ Frontend TypeScript errors found!" -ForegroundColor Red
    Set-Location client
    npx vue-tsc --noEmit
    Set-Location ..
    exit 1
}

# 5. Backend Linting
Write-Host ""
Write-Host "5️⃣  Checking Backend Linting..." -ForegroundColor Yellow
try {
    npm run lint 2>&1 | Out-Null
    Write-Host "✅ Backend Linting OK" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend linting errors found!" -ForegroundColor Red
    npm run lint
    exit 1
}

# 6. Frontend Linting
Write-Host ""
Write-Host "6️⃣  Checking Frontend Linting..." -ForegroundColor Yellow
Set-Location client
try {
    npm run lint 2>&1 | Out-Null
    Write-Host "✅ Frontend Linting OK" -ForegroundColor Green
    Set-Location ..
} catch {
    Set-Location ..
    Write-Host "❌ Frontend linting errors found!" -ForegroundColor Red
    Set-Location client
    npm run lint
    Set-Location ..
    exit 1
}

# 7. Tests
if (-not $skipTests) {
    Write-Host ""
    Write-Host "7️⃣  Running Tests..." -ForegroundColor Yellow
    try {
        npm test -- --run 2>&1 | Out-Null
        Write-Host "✅ Tests OK" -ForegroundColor Green
    } catch {
        Write-Host "❌ Tests failed!" -ForegroundColor Red
        npm test -- --run
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "ℹ️  Skipping tests (use --skip-tests to skip)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🎉 All checks passed! ✅" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

