$LogPath = ".\Simulations\network_perimeter_triage.log"
$TargetIP = "192.168.10.50" # IP del Core Financiero Afectado
$TargetPort_Web = 443
$TargetPort_DNS = 53

$BotNet_IPs = @("185.220.101.5", "45.146.164.12", "193.56.28.94", "91.241.19.82", "141.98.10.43")
$UserAgents = @(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Go-http-client/1.1",
    "sqlmap/1.6.3#stable (https://sqlmap.org)",
    "Mozilla/5.0 (compatible; Nmap Scripting Engine; https://nmap.org)"
)

$Malicious_Payloads = @(
    "POST /api/v1/auth/login HTTP/1.1; Host: ://corefinance.com; User-Agent: {0}; Payload: admin' OR '1'='1" ,
    "GET /api/v1/transfer?account=../../etc/passwd HTTP/1.1; Host: ://corefinance.com; User-Agent: {0}; Payload: Path_Traversal",
    "POST /api/v1/transfer HTTP/1.1; Host: ://corefinance.com; User-Agent: {0}; Payload: Account_Enumeration_Bot"
)

$LogEntries = @()
$Timestamp = [DateTime]::UtcNow

Write-Output "Iniciando simulación de generación de tráfico híbrido masivo (L3/L4/L7)..."

# Generación de ráfagas volumétricas L3/L4 (SYN Flood y Amplificación DNS)
for ($i = 1; $i -le 1500; $i++) {
    $SrcIP = "103.245.140." + (Get-Random -Minimum 1 -Maximum 254)
    $SrcPort = Get-Random -Minimum 1024 -Maximum 65535
    $TimeStr = $Timestamp.AddMilliseconds((Get-Random -Minimum 1 -Maximum 5000)).ToString("yyyy-MM-dd HH:mm:ss.fff")
    
    # TCP SYN Flood
    if ($i % 3 -eq 0) {
        $LogEntries += "[$TimeStr] [LAYER3/4] SRC_IP=$SrcIP SRC_PORT=$SrcPort -> DST_IP=$TargetIP DST_PORT=$TargetPort_Web FLAGS=[SYN] SEQ_NUM=$(Get-Random) LEN=0"
    }
    # DNS Amplification (Spoofed Source targeting the server or high reflection vectors)
    else {
        $LogEntries += "[$TimeStr] [LAYER4] SRC_IP=$(Get-Random $BotNet_IPs) SRC_PORT=$TargetPort_DNS -> DST_IP=$TargetIP DST_PORT=$SrcPort PROTO=UDP TYPE=DNS_REPLY_ANY LEN=1420"
    }
}

# Generación de ataques selectivos de Capa 7 (OWASP & Evasión de Rate Limiting)
for ($j = 1; $j -le 500; $j++) {
    $TimeStr = $Timestamp.AddMilliseconds((Get-Random -Minimum 5001 -Maximum 10000)).ToString("yyyy-MM-dd HH:mm:ss.fff")
    $SelectedIP = Get-Random $BotNet_IPs
    $SelectedUA = Get-Random $UserAgents
    $RawPayload = Get-Random $Malicious_Payloads
    $FormattedPayload = $RawPayload -f $SelectedUA
    
    $LogEntries += "[$TimeStr] [LAYER7] SRC_IP=$SelectedIP -> DST_IP=$TargetIP DST_PORT=$TargetPort_Web REQ=[$FormattedPayload]"
}

# Escribir los registros ordenados temporalmente en el archivo final
$LogEntries | Sort-Object | Out-File -FilePath $LogPath -Encoding utf8
Write-Output "Archivo de log generado exitosamente en: $LogPath"
Write-Output "Total de registros inyectados: $($LogEntries.Count)"
