# ==============================================================================
# Script de validacion rapida de entorno (PowerShell) - Claude Build Day @ SCD Mexico 2026
# Mentor: Roberto Flores (Siegfried)
# ==============================================================================

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Claude Build Day @ Student Community Day Mexico 2026          " -ForegroundColor Cyan
Write-Host "  Verificacion de entorno local / cloud (Fase 1: Setup seguro)  " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$errorsCount = 0

# 0. Verificar ExecutionPolicy de PowerShell
Write-Host -NoNewline "0. Verificando ExecutionPolicy de PowerShell... "
$policy = Get-ExecutionPolicy
if ($policy -eq 'Restricted') {
    Write-Host "[RESTRINGIDO]" -ForegroundColor Yellow
    Write-Host "   `- Para permitir scripts ejecuta: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
} else {
    Write-Host "[OK] $policy" -ForegroundColor Green
}

# 1. Verificar Claude Code CLI
Write-Host -NoNewline "1. Verificando Claude Code CLI... "
if (Get-Command claude -ErrorAction SilentlyContinue) {
    $claudeVer = (claude --version 2>&1 | Select-Object -First 1).Trim()
    Write-Host "[OK] $claudeVer" -ForegroundColor Green
} else {
    # Revisar si existe en AppData o .local pero falta recargar PATH
    $possibleLocal = Join-Path $env:USERPROFILE ".local\bin\claude.exe"
    $possibleApp = Join-Path $env:LOCALAPPDATA "Programs\claude\claude.exe"
    if ((Test-Path $possibleLocal) -or (Test-Path $possibleApp)) {
        Write-Host "[INSTALADO PERO FUERA DE PATH]" -ForegroundColor Yellow
        Write-Host "   `- Cierra y vuelve a abrir PowerShell para que reconozca el comando claude."
        Write-Host "   `- O corre: `$env:Path = [System.Environment]::GetEnvironmentVariable('Path','User') + ';' + [System.Environment]::GetEnvironmentVariable('Path','Machine')"
    } else {
        Write-Host "[FALTA] Claude Code CLI no esta instalado." -ForegroundColor Red
        Write-Host "   `- Instalacion oficial (sin Node.js): irm https://claude.ai/install.ps1 | iex"
        $errorsCount++
    }
}

# 2. Verificar credenciales de Anthropic
Write-Host -NoNewline "2. Verificando credenciales de Anthropic... "
$apiKey = $env:ANTHROPIC_API_KEY
if (-not $apiKey) {
    $apiKey = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_API_KEY", "User")
}
$claudeConfig = Join-Path $env:USERPROFILE ".claude.json"
if ($apiKey) {
    $len = $apiKey.Length
    $masked = if ($len -gt 12) { $apiKey.Substring(0, 10) + "..." + $apiKey.Substring($len - 4) } else { "sk-ant-***" }
    Write-Host "[OK] Variable ANTHROPIC_API_KEY detectada ($masked)" -ForegroundColor Green
} elseif (Test-Path $claudeConfig) {
    Write-Host "[OK] Sesion web configurada en .claude.json" -ForegroundColor Green
} else {
    Write-Host "[PENDIENTE] Aun no has ejecutado /login dentro de Claude Code." -ForegroundColor Yellow
}

# 3. Verificar uv (Gestor de herramientas)
Write-Host -NoNewline "3. Verificando uv... "
if (Get-Command uv -ErrorAction SilentlyContinue) {
    $uvVer = (uv --version 2>&1 | Select-Object -First 1).Trim()
    Write-Host "[OK] $uvVer" -ForegroundColor Green
} else {
    Write-Host "[AUTO-GESTIONADO] uv no detectado manualmente." -ForegroundColor Yellow
    Write-Host "   `- El agente lo instalara de forma autonoma durante el setup."
}

# 4. Verificar AWS CLI v2
Write-Host -NoNewline "4. Verificando AWS CLI v2... "
if (Get-Command aws -ErrorAction SilentlyContinue) {
    $awsVer = (aws --version 2>&1).Split(' ')[0]
    Write-Host "[OK] $awsVer" -ForegroundColor Green
} else {
    Write-Host "[AUTO-GESTIONADO] aws-cli no detectado." -ForegroundColor Yellow
    Write-Host "   `- El agente lo instalara de forma autonoma con el prompt oficial."
}

# 5. Verificar Node.js (Opcional)
Write-Host -NoNewline "5. Verificando Node.js (opcional para desarrollo web)... "
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVer = (node -v).Trim()
    Write-Host "[OK] $nodeVer" -ForegroundColor Green
} else {
    Write-Host "[OPCIONAL] No detectado (el instalador nativo no lo requiere)." -ForegroundColor Yellow
}

# 6. Verificar sesion activa de AWS
Write-Host -NoNewline "6. Verificando sesion activa de AWS... "
if (Get-Command aws -ErrorAction SilentlyContinue) {
    try {
        $stsJson = aws sts get-caller-identity --output json 2>$null | ConvertFrom-Json
        if ($stsJson -and $stsJson.Account) {
            Write-Host "[OK] Conectado a cuenta: $($stsJson.Account)" -ForegroundColor Green
            Write-Host "   `- Identidad: $($stsJson.Arn)" -ForegroundColor Cyan
        } else {
            Write-Host "[PENDIENTE] Sin sesion activa aun. Se enlazara en el Paso 3 con aws login." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[PENDIENTE] Sin sesion activa aun. Se enlazara en el Paso 3 con aws login." -ForegroundColor Yellow
    }
} else {
    Write-Host "[PENDIENTE] Se configurara durante el taller." -ForegroundColor Yellow
}

# Resumen final
Write-Host ""
Write-Host "----------------------------------------------------------------"
if ($errorsCount -eq 0) {
    Write-Host "[ESTADO] Entorno preparado para el taller." -ForegroundColor Green
    Write-Host "Listo para continuar con Fase 2 (Juan Mejia) y Fase 3 (Joselyn Lagunas)."
} else {
    Write-Host "[ESTADO] Se encontraron $errorsCount punto(s) de revision." -ForegroundColor Yellow
    Write-Host "Revisa los pasos en el README.md o con el mentor Roberto Flores (Siegfried)."
}
Write-Host "----------------------------------------------------------------"
Write-Host ""
