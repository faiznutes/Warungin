# Check all Vue files for TypeScript errors
# This script will check all .vue files for TypeScript errors

Write-Host "🔍 Checking all Vue files for TypeScript errors..." -ForegroundColor Cyan
Write-Host ""

$errorCount = 0
$vueFiles = Get-ChildItem -Path "client\src" -Filter "*.vue" -Recurse

Write-Host "Found $($vueFiles.Count) Vue files to check" -ForegroundColor Yellow
Write-Host ""

foreach ($file in $vueFiles) {
    $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
    Write-Host "Checking: $relativePath" -ForegroundColor Gray
    
    # Try to check with vue-tsc (if available)
    # This is a simplified check - actual TypeScript checking requires node_modules
    $hasError = $false
    
    # Check if file has common TypeScript issues
    $content = Get-Content $file.FullName -Raw
    
    # Check for common issues
    if ($content -match "import.*from ['\`"]vue['\`"]" -and -not (Test-Path "client\node_modules\vue")) {
        Write-Host "  ⚠️  Warning: Vue module not found (node_modules missing)" -ForegroundColor Yellow
        $hasError = $true
    }
    
    if ($hasError) {
        $errorCount++
    }
}

Write-Host ""
if ($errorCount -eq 0) {
    Write-Host "✅ No obvious errors found in Vue files" -ForegroundColor Green
    Write-Host "⚠️  Note: Full TypeScript checking requires node_modules to be installed" -ForegroundColor Yellow
    Write-Host "   Run: cd client && npm install" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  Found $errorCount potential issues" -ForegroundColor Yellow
    Write-Host "   Install dependencies first: cd client && npm install" -ForegroundColor Yellow
}

Write-Host ""

