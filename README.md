# Enterprise MDR & Perimeter Security Operations

## Inventario de Archivos Activos
* SOAR_Automation/botnet_iocs.json: Base de datos estructurada con los IOCs de la Botnet Remnante.
* SOAR_Automation/Edge_Containment_SOAR.ps1: Playbook automatizado en PowerShell para la contencion.
* ZeroTrust_Architecture/api_hardening_policy.json: Especificacion de arquitectura y politica de Circuit Breaker.

## Instrucciones de Ejecucion
Para lanzar la contencion automatizada ejecute desde la raiz:
. .\SOAR_Automation\Edge_Containment_SOAR.ps1
