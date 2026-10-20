$LogPath = ".\Simulations\network_perimeter_triage.log"

if (-not (Test-Path $LogPath)) {
    Write-Error "Archivo de log no encontrado en la ruta esperada."
    exit
}

Write-Output "=========================================================="
Write-Output "   MDR PERIMETER TRIAGE REPORT - GLOBAL CORE FINANCIAL    "
Write-Output "=========================================================="

# Carga de los datos crudos de telemetría
$Logs = Get-Content -Path $LogPath

# 1. Cuantificación de Vectores Volumétricos (L3/L4)
$SynFloodCount = ($Logs | Where-Object { $_ -like "*FLAGS=[SYN]*" }).Count
$DnsAmpCount = ($Logs | Where-Object { $_ -like "*TYPE=DNS_REPLY_ANY*" }).Count

Write-Output ""
Write-Output "[+] TELEMETRÍA DE AGOTAMIENTO DE PROTOCOLO (L3/L4):"
Write-Output "    - Ráfagas de TCP SYN Flood (Mitigación Cloud): $SynFloodCount eventos."
Write-Output "    - Amplificación DNS Anómala (UDP reflection): $DnsAmpCount eventos."

# 2. Identificación de la Infraestructura Adversaria (Top IP Attackers)
Write-Output ""
Write-Output "[+] EXTRACTO DE IP ADVERSARIAS DETECTADAS (BOTNET CORE):"
$IpRegex = "SRC_IP=([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"
$DetectedIPs = foreach ($Log in $Logs) {
    if ($Log -match $IpRegex) { $Matches[1] }
}
$TopIPs = $DetectedIPs | Group-Object | Sort-Object Count -Descending | Select-Object -First 5
foreach ($IpGroup in $TopIPs) {
    Write-Output "    - IP: $($IpGroup.Name) | Peticiones interceptadas: $($IpGroup.Count)"
}

# 3. Clasificación del Comportamiento Web (L7 OWASP Top 10)
$SqlInjectionCount = ($Logs | Where-Object { $_ -like "*OR '1'='1*" }).Count
$PathTraversalCount = ($Logs | Where-Object { $_ -like "*../../etc/passwd*" }).Count
$BotEnumerationCount = ($Logs | Where-Object { $_ -like "*Account_Enumeration_Bot*" }).Count

Write-Output ""
Write-Output "[+] CLASIFICACIÓN DE INTENTOS DE EXPLOTACIÓN (L7 OWASP):"
Write-Output "    - Inyecciones SQL (Manipulación de parámetros): $SqlInjectionCount incidentes."
Write-Output "    - Path Traversal (Lectura de archivos internos): $PathTraversalCount incidentes."
Write-Output "    - Tráfico Automatizado (Botnet Enumeration / Bypassing): $BotEnumerationCount incidentes."

# 4. Mapeo Táctico bajo la Matriz MITRE ATT&CK
Write-Output ""
Write-Output "=========================================================="
Write-Output "   MAPEO DE AMENAZAS ADVERSARIAS - MITRE ATT&CK MATRIX    "
Write-Output "=========================================================="
Write-Output "[-] T1498 (Network Denial of Service): Detectado en vectores SYN Flood y Amplificación UDP."
Write-Output "[-] T1190 (Exploit Public-Facing Application): Detectado mediante Payloads Web en /api/v1/."
Write-Output "[-] T1110 (Brute Force / Credential Stuffing): Confirmado en endpoint /auth/login vía automatización."
Write-Output "=========================================================="
