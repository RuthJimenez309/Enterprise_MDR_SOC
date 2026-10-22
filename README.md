# Enterprise MDR & Perimeter Security Operations

## Inventario de Archivos Activos
* SOAR_Automation/botnet_iocs.json: Base de datos estructurada con los IOCs de la Botnet Remnante.
* SOAR_Automation/Edge_Containment_SOAR.ps1: Playbook automatizado en PowerShell para la contencion.
* ZeroTrust_Architecture/api_hardening_policy.json: Especificacion de arquitectura y politica de Circuit Breaker.

## Instrucciones de Ejecucion
Para lanzar la contencion automatizada ejecute desde la raiz:
. .\SOAR_Automation\Edge_Containment_SOAR.ps1

## Componentes de Telemetria y Analisis Forense (Dia 23)
* **Telemetry_Engine/Telemetry_Schema.json**: Almacen local descentralizado estructurado en formato JSON para eventos perimetrales y telemetria forense.
* **Telemetry_Engine/Forensic_Evidence_Collector.ps1**: Modulo de recoleccion forense encargado de analizar el Working Set de memoria volatil, sockets de red y logs de auditoria.
* **Telemetry_Engine/Edge_Behavioral_Engine.ps1**: Motor analitico de deteccion de anomalias por comportamiento basado en desviaciones dinamicas de carga util y rafagas de sesion.
