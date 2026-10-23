param (
    [string]$TargetEndpoint = "/api/v1/financial/settlements",
    [string]$RequestMethod = "POST",
    [string]$SourceIp = "192.168.142.55",
    [int]$RecentAuthFailures = 6
)

# Cargar el esquema de decepción persistente
$schemaPath = "deception_schema.json"
if (-not (Test-Path $schemaPath)) {
    Write-Error "Error: No se encontro deception_schema.json"
    exit 1
}
$schema = Get-Content -Path $schemaPath | ConvertFrom-Json

# Inicializar banderas de correlación
$honeyTokenTriggered = $false
$metricThresholdExceeded = $false
$finalIncidentSeverity = "LOW"

# Evaluacion 1: Mecanismo de Honey-Token / Deception
if ($TargetEndpoint -eq $schema.HoneyToken.EndpointPath -and $RequestMethod -eq $schema.HoneyToken.ExpectedMethod) {
    $honeyTokenTriggered = $true
    Start-Sleep -Milliseconds $schema.HoneyToken.ResponseDelayMs
}

# Evaluacion 2: Correlacion de Metricas Cruzadas (Umbrales Dinámicos)
if ($RecentAuthFailures -gt $schema.MetricsThresholds.MaxAuthAttemptsPerMinute) {
    $metricThresholdExceeded = $true
}

# Logica del Motor de Correlacion Avanzada
$alertMessage = "Evento analizado de forma estandar."
if ($honeyTokenTriggered -and $metricThresholdExceeded) {
    $finalIncidentSeverity = "CRITICAL"
    $alertMessage = "CORRELACION DETECTADA: Intento de fuerza bruta seguido de acceso directo a Honey-Token Financiero."
} elseif ($honeyTokenTriggered) {
    $finalIncidentSeverity = $schema.HoneyToken.AlertSeverity
    $alertMessage = "DECEPCION TACTICA: Acceso directo al endpoint ficticio sin fase de reconocimiento previa."
} elseif ($metricThresholdExceeded) {
    $finalIncidentSeverity = "MEDIUM"
    $alertMessage = "ANOMALIA DE METRICA: Multiples fallos de autenticacion detectados en la ventana temporal."
}

# Estructurar la telemetria capturada
$newEvent = @{
    Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    SourceIp  = $SourceIp
    Endpoint  = $TargetEndpoint
    Severity  = $finalIncidentSeverity
    Message   = $alertMessage
}

# Persistir la alerta dentro del historico del esquema JSON
$schema.TelemetryLog += $newEvent
$schema | ConvertTo-Json -Depth 5 | Out-File -FilePath $schemaPath -Encoding utf8

# Desplegar resultado por consola para el analista del SOC
Write-Output "=== ENTERPRISE MDR PERIMETER SECURITY CORRELATION ENGINE ==="
Write-Output "Severidad Final: $finalIncidentSeverity"
Write-Output "Detalle: $alertMessage"
Write-Output "Registro actualizado en persistencia local."
