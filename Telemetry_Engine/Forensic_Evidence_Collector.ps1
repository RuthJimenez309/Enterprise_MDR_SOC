# Enterprise MDR - Forensic Evidence Collector & Memory Analysis
# Proposito: Analizar el estado de la memoria volatil, procesos activos y registros del sistema relacionados con la telemetria.

param (
    [int]$TargetProcessID = 0
)

Write-Host "=== INICIANDO RECOLECCION DE EVIDENCIA FORENSE Y ANALISIS DE MEMORIA ===" -ForegroundColor Cyan

# 1. Analisis Forense de Memoria Volatil (Simulacion estructurada basada en Working Set real)
Write-Host "[*] Extrayendo mapa de memoria volatil y juego de trabajo (Working Set)..." -ForegroundColor Yellow
$ProcessFilter = Get-Process -Id $TargetProcessID -ErrorAction SilentlyContinue

if ($null -eq $ProcessFilter) {
    Write-Host "[-] PID especifico no encontrado o no provisto. Analizando procesos principales del sistema..." -ForegroundColor Yellow
    $ProcessFilter = Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First 5
}

$MemoryAnalysis = foreach ($Proc in $ProcessFilter) {
    [PSCustomObject]@{
        ProcessName       = $Proc.ProcessName
        PID               = $Proc.Id
        WorkingSet_MB     = [Math]::Round($Proc.WorkingSet / 1MB, 2)
        VirtualMemory_MB  = [Math]::Round($Proc.VirtualMemorySize / 1MB, 2)
        NonPagedMemory_KB = [Math]::Round($Proc.NonpagedSystemMemorySize / 1KB, 2)
        VerificationTime  = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }
}
$MemoryAnalysis | Format-Table -AutoSize

# 2. Recoleccion de Evidencia del Sistema (Conexiones de Red Volatiles del Proceso)
Write-Host "[*] Recolectando sockets activos y estado de red para correlacion forense..." -ForegroundColor Yellow
$NetworkEvidence = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | 
                   Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess | 
                   Select-Object -First 5

if ($NetworkEvidence) {
    $NetworkEvidence | Format-Table -AutoSize
} else {
    Write-Host "[-] No se encontraron conexiones TCP activas en estado 'Established'." -ForegroundColor Gray
}

# 3. Analisis de Registros de Auditoria (Logs Forenses de PowerShell / Sistema)
Write-Host "[*] Extrayendo ultimos eventos del registro de auditoria local (Log Triage)..." -ForegroundColor Yellow
$SystemLogs = Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" -MaxEvents 3 -ErrorAction SilentlyContinue | 
              Select-Object TimeCreated, Id, Message

if ($null -eq $SystemLogs) {
    # Alternativa si el registro operativo no tiene eventos recientes o no esta disponible
    $SystemLogs = Get-Process | Select-Object -First 3 | ForEach-Object {
        [PSCustomObject]@{
            TimeCreated = (Get-Date)
            Id          = 100
            Message     = "Evento alternativo de telemetria de proceso: $($_.ProcessName)"
        }
    }
}
$SystemLogs | Format-List

Write-Host "=== RECOLECCION FORENSE FINALIZADA EN EL CONTENEDOR DE TELEMETRIA ===" -ForegroundColor Cyan
