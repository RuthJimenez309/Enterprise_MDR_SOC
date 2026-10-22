# Enterprise MDR - Edge Behavioral Anomaly Engine
# Proposito: Analizar el flujo de solicitudes sin firmas estaticas, evaluando desviaciones de carga y rafagas de sesion.

Write-Host "=== INICIANDO MOTOR DE DETECCION DE ANOMALIAS POR COMPORTAMIENTO ===" -ForegroundColor Cyan

# 1. Cargar el almacen de telemetria descentralizado
$LogPath = "Telemetry_Engine\Telemetry_Schema.json"
if (-not (Test-Path $LogPath)) {
    Write-Error "No se encontro el archivo de telemetria: $LogPath"
    return
}

$Events = Get-Content -Raw -Path $LogPath | ConvertFrom-Json
Write-Host "[*] Telemetria cargada con exito. Analizando $($Events.Count) eventos..." -ForegroundColor Gray

# 2. CALCULO MATEMATICO DE PROMEDIOS Y UMBRALES DINAMICOS (Payload Size Analysis)
$PayloadSizes = $Events.Payload_Size_Bytes
$AveragePayload = ($PayloadSizes | Measure-Object -Average).Average
# Establecemos un umbral dinamico de desviacion: 2 veces el tamaño promedio habitual
$AnomalyThresholdBytes = $AveragePayload * 2

Write-Host "[*] Analisis Base de Carga Util:" -ForegroundColor Yellow
Write-Host "    -> Carga util promedio calculada: [ $AveragePayload Bytes ]" -ForegroundColor Gray
Write-Host "    -> Umbral dinamico de anomalia establecido: [ $AnomalyThresholdBytes Bytes ]" -ForegroundColor Gray

# 3. EVALUACION PERIMETRAL DE EVENTOS Y DETECCION DE ANOMALIAS
foreach ($Event in $Events) {
    $IsAnomalous = $false
    $Reason = @()

    # Evaluacion de Objetivo 1: Desviacion de Carga Util
    if ($Event.Payload_Size_Bytes -gt $AnomalyThresholdBytes) {
        $IsAnomalous = $true
        $Reason += "Tamano de carga util anomalo ($($Event.Payload_Size_Bytes) Bytes)"
    }

    # Evaluacion de Objetivo 2: Frecuencia de Rafaga por Sesion
    $SessionHits = ($Events | Where-Object { $_.SessionID -eq $Event.SessionID }).Count
    if ($SessionHits -ge 3) {
        $IsAnomalous = $true
        $Reason += "Frecuencia de rafaga critica detectada en sesion ($SessionHits solicitudes)"
    }

    # Procesar Alerta si se confirma un comportamiento fuera de lo normal
    if ($IsAnomalous) {
        Write-Host ""
        Write-Host "[ALERT] Anomalia perimetral detectada en Evento ID: $($Event.EventID)" -ForegroundColor Red
        Write-Host "    -> Sesion Anonimizada: $($Event.SessionID)" -ForegroundColor DarkYellow
        Write-Host "    -> Razon del Dictamen: $($Reason -join ' + ')" -ForegroundColor DarkYellow
        
        # Integracion Automatizada con el Recolector Forense (Memory Analysis Integration)
        $TargetPID = $Event.Forensic_Context.ProcessID
        Write-Host "    -> Desplegando recolector forense para analizar el PID asociado: $TargetPID..." -ForegroundColor Yellow
        
        if (Test-Path "Telemetry_Engine\Forensic_Evidence_Collector.ps1") {
            . "Telemetry_Engine\Forensic_Evidence_Collector.ps1" -TargetProcessID $TargetPID
        }
    } else {
        Write-Host "[Normal] Evento ID: $($Event.EventID) bajo la sesion $($Event.SessionID) cumple los parametros de comportamiento de la linea base." -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== EVALUACION COMPORTAMENTAL COMPLETADA ===" -ForegroundColor Cyan
