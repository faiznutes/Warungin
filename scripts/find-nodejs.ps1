# Find Node.js installation
Write-Host "🔍 Searching for Node.js installation..." -ForegroundColor Cyan
Write-Host ""

$found = $false
$paths = @(
    "C:\Program Files\nodejs",
    "C:\Program Files (x86)\nodejs",
    "$env:APPDATA\npm",
    "$env:LOCALAPPDATA\Programs\nodejs",
    "$env:ProgramFiles\nodejs",
    "$env:ProgramFiles(x86)\nodejs"
)

foreach ($path in $paths) {
    $nodePath = Join-Path $path "node.exe"
    $npmPath = Join-Path $path "npm.cmd"
    
    if (Test-Path $nodePath) {
        Write-Host "✅ Found Node.js at: $path" -ForegroundColor Green
        Write-Host "   Node: $nodePath" -ForegroundColor Gray
        if (Test-Path $npmPath) {
            Write-Host "   npm: $npmPath" -ForegroundColor Gray
        }
        $found = $true
        
        # Try to get version
        try {
            $version = & $nodePath --version
            Write-Host "   Version: $version" -ForegroundColor Green
        } catch {
            Write-Host "   (Could not get version)" -ForegroundColor Yellow
        }
        Write-Host ""
    }
}

if (-not $found) {
    Write-Host "❌ Node.js not found in common locations" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Node.js from: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "Make sure to check 'Add to PATH' during installation" -ForegroundColor Yellow
} else {
    Write-Host "💡 To use Node.js, you can:" -ForegroundColor Cyan
    Write-Host "   1. Add Node.js to PATH manually" -ForegroundColor White
    Write-Host "   2. Use full path to npm: & 'C:\Program Files\nodejs\npm.cmd' install" -ForegroundColor White
    Write-Host "   3. Restart your terminal/IDE after installation" -ForegroundColor White
}

