# =====================================================================
#  deploy-iis.ps1  -  Despliegue de WebAppPoliMusicV1 en IIS
#
#  EJECUTAR COMO ADMINISTRADOR (click derecho > Ejecutar con PowerShell
#  como administrador, o desde una consola elevada):
#
#      powershell -ExecutionPolicy Bypass -File .\deploy-iis.ps1
#
#  El script:
#    1. Verifica que Classic ASP este habilitado en IIS (lo instala si falta).
#    2. Copia la aplicacion a C:\inetpub\wwwroot\webapppolimusicv1_asp
#    3. Crea/actualiza la aplicacion IIS con su propio Application Pool.
#    4. Otorga permisos a IIS sobre la carpeta y sobre los assets.
#    5. Comprueba que el sitio responde.
# =====================================================================

[CmdletBinding()]
param(
    [string]$SourcePath = "C:\Users\WebAvanzadas\source\repos\AppWebAvGregorySalazar\webapppolimusicv1_asp",
    [string]$SiteName   = "Default Web Site",
    [string]$AppName    = "webapppolimusicv1_asp",
    [string]$AppPool    = "PoliMusicPool",
    [int]   $Port       = 80
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Text) {
    Write-Host ""
    Write-Host "==> $Text" -ForegroundColor Cyan
}

function Assert-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "ERROR: este script debe ejecutarse como Administrador." -ForegroundColor Red
        Write-Host "Abra PowerShell como administrador y vuelva a ejecutarlo." -ForegroundColor Yellow
        exit 1
    }
}

Assert-Admin

# ---------------------------------------------------------------------
Write-Step "1/6  Verificando que Classic ASP este habilitado"

$aspFeature = Get-WindowsOptionalFeature -Online -FeatureName "IIS-ASP" -ErrorAction SilentlyContinue
if ($null -eq $aspFeature) {
    Write-Host "No se pudo consultar la caracteristica IIS-ASP (puede requerir Windows Server)." -ForegroundColor Yellow
}
elseif ($aspFeature.State -ne "Enabled") {
    Write-Host "Classic ASP no esta habilitado. Habilitandolo..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName "IIS-ASP" -All -NoRestart | Out-Null
    Write-Host "Classic ASP habilitado." -ForegroundColor Green
}
else {
    Write-Host "Classic ASP ya esta habilitado." -ForegroundColor Green
}

Import-Module WebAdministration

# ---------------------------------------------------------------------
#  Configuracion de Classic ASP A NIVEL DE SERVIDOR
#
#  La seccion "system.webServer/asp" esta bloqueada por defecto
#  (overrideModeDefault="Deny"), por lo que NO se puede declarar en el
#  web.config de la aplicacion: hacerlo produce HTTP 501.
#  Debe configurarse aqui, contra applicationHost.config.
#
#  Se fijan explicitamente los valores necesarios:
#    - scriptErrorSentToBrowser = false  (no exponer errores al cliente)
#    - enableParentPaths        = false  (la app usa includes "virtual=",
#                                         no necesita rutas padre)
#    - session.timeout          = 00:20:00
# ---------------------------------------------------------------------
Write-Host "Configurando Classic ASP a nivel de servidor..." -ForegroundColor Cyan
try {
    Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" `
        -Filter "system.webServer/asp" -Name "scriptErrorSentToBrowser" -Value "False"
    Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" `
        -Filter "system.webServer/asp" -Name "enableParentPaths" -Value "False"
    Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" `
        -Filter "system.webServer/asp/session" -Name "allowSessionState" -Value "True"
    Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" `
        -Filter "system.webServer/asp/session" -Name "timeout" -Value "00:20:00"
    Write-Host "Classic ASP configurado (scriptErrorSentToBrowser=false, enableParentPaths=false)." -ForegroundColor Green
} catch {
    Write-Host "Aviso: no se pudo fijar toda la configuracion de ASP: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "       La aplicacion funciona igual con los valores por defecto de IIS." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------
Write-Step "2/6  Verificando origen"

if (-not (Test-Path $SourcePath)) {
    Write-Host "ERROR: no existe la carpeta origen: $SourcePath" -ForegroundColor Red
    exit 1
}
$destPath = Join-Path "C:\inetpub\wwwroot" $AppName
Write-Host "Origen : $SourcePath"
Write-Host "Destino: $destPath"

# ---------------------------------------------------------------------
Write-Step "3/6  Copiando archivos"

if (-not (Test-Path "C:\inetpub\wwwroot")) {
    New-Item -ItemType Directory -Path "C:\inetpub\wwwroot" -Force | Out-Null
}
if (-not (Test-Path $destPath)) {
    New-Item -ItemType Directory -Path $destPath -Force | Out-Null
}

# /MIR espeja el contenido, /XD excluye carpetas de herramientas locales.
$robocopyArgs = @(
    $SourcePath, $destPath,
    "/MIR", "/NFL", "/NDL", "/NJH", "/NJS", "/NC", "/NS", "/NP",
    "/XD", ".vs", "obj", "bin"
)
& robocopy @robocopyArgs | Out-Null
if ($LASTEXITCODE -ge 8) {
    Write-Host "ERROR: robocopy fallo con codigo $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
Write-Host "Archivos copiados." -ForegroundColor Green

# El archivo de desarrollo de IIS Express no debe desplegarse.
$devConfig = Join-Path $destPath "iisexpress.config"
if (Test-Path $devConfig) { Remove-Item $devConfig -Force }

# Registrar el tipo MIME del audio a nivel de servidor si faltara.
# (El web.config tambien lo declara; esto evita depender de que pueda
#  sobreescribirse en todos los entornos.)
try {
    Add-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" `
        -Filter "system.webServer/staticContent" -Name "." `
        -Value @{ fileExtension = ".mp3"; mimeType = "audio/mpeg" } -ErrorAction SilentlyContinue
} catch { }

# ---------------------------------------------------------------------
Write-Step "4/6  Creando Application Pool y aplicacion IIS"

if (-not (Test-Path "IIS:\AppPools\$AppPool")) {
    New-WebAppPool -Name $AppPool | Out-Null
    Write-Host "Application Pool '$AppPool' creado." -ForegroundColor Green
}
# ASP clasico requiere modo 32/64 bits coherente; se usa Integrated + v4.0.
Set-ItemProperty "IIS:\AppPools\$AppPool" -Name managedRuntimeVersion   -Value "v4.0"
Set-ItemProperty "IIS:\AppPools\$AppPool" -Name managedPipelineMode     -Value "Integrated"
Set-ItemProperty "IIS:\AppPools\$AppPool" -Name enable32BitAppOnWin64   -Value $false

$appPath = "/" + $AppName
if (Get-WebApplication -Site $SiteName -Name $AppName -ErrorAction SilentlyContinue) {
    Set-ItemProperty "IIS:\Sites\$SiteName\$AppName" -Name physicalPath     -Value $destPath
    Set-ItemProperty "IIS:\Sites\$SiteName\$AppName" -Name applicationPool  -Value $AppPool
    Write-Host "Aplicacion '$appPath' actualizada." -ForegroundColor Green
} else {
    New-WebApplication -Site $SiteName -Name $AppName -PhysicalPath $destPath -ApplicationPool $AppPool | Out-Null
    Write-Host "Aplicacion '$appPath' creada." -ForegroundColor Green
}

# ---------------------------------------------------------------------
Write-Step "5/6  Otorgando permisos a IIS"

$aclTargets = @($destPath, (Join-Path $destPath "assets"))
foreach ($t in $aclTargets) {
    if (Test-Path $t) {
        icacls $t /grant "IIS_IUSRS:(OI)(CI)RX" /T /Q | Out-Null
        icacls $t /grant "IUSR:(OI)(CI)RX"      /T /Q | Out-Null
    }
}
Write-Host "Permisos de lectura otorgados a IIS_IUSRS e IUSR." -ForegroundColor Green

# ---------------------------------------------------------------------
Write-Step "6/6  Reiniciando y comprobando"

Restart-WebAppPool -Name $AppPool -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

$url = "http://localhost$(':' + $Port)$appPath/login.asp"
Write-Host "Probando: $url"

try {
    $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 20
    $ok   = ($resp.StatusCode -eq 200) -and ($resp.Content -match "PoliMusic")
    if ($ok) {
        Write-Host "DESPLIEGUE CORRECTO. El sitio responde en:" -ForegroundColor Green
        Write-Host "   $url" -ForegroundColor Green
    } else {
        Write-Host "El sitio respondio $($resp.StatusCode) pero el contenido no parece correcto." -ForegroundColor Yellow
    }
} catch {
    Write-Host "No se pudo verificar la URL: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "Revise que el sitio '$SiteName' este iniciado y escuchando en el puerto $Port." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Credenciales de prueba: userAdmin / 12345678  (administrador)" -ForegroundColor Cyan
Write-Host "                        userNormal / 12345678  (usuario normal)" -ForegroundColor Cyan
Write-Host ""
