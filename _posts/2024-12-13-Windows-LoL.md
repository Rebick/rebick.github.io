---
layout: post
author: Sergio Salgado
---
# [](#header-1)The Lay of the Land
## [](#header-2)Indice
- <a href="#enumeracion_soluciones_seguridad">Enumeracion de soluciones de seguridad</a>
  - <a href="#enumeracion_antivirus">Enumeracion de antivirus</a>

## [](#header-2)<a id="enumeracion_soluciones_seguridad">Enumeracion de soluciones de seguridad</a>


### [](#header-3)<a id="enumeracion_antivirus">Enumeracion de antivirus</a>

```s
wmic /namespace:\\root\securitycenter2 path antivirusproduct

Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct
#windows server no tiene SecurityCenter2, solo las workstations

#Para obtener el estatus de las soluciones de seguridad, podemos usar el comando Get-MpComputerStatus y filtramos los elementos con select, pueden ser los mas utiles(Spyware, Antivirus, LoavProtection, Real-time protection)
Get-MpComputerStatus | select RealTimeProtectionEnabled
```
### [](#header-3)<a id="enumeracion_firewall">Enumeracion de firewall</a>

```s
Get-NetFirewallProfile | Format-Table Name, Enabled
#Para aprender sobre las reglas de permisos y denegaciones
Get-NetFirewallRule | select DisplayName, Enabled, Description
#Con permisos de administrador, podremos desactivarlo de la forma:
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
```

Enumeracion del sistema
```powershell
#Aplicaciones instaladas en el sistema
wmic product get name,version
#Archivos escondidos
Get-ChildItem -Hidden -Path "$env:USERPROFILE\Desktop\"

#Servicios corriendo dentro del sistema
net start
#Si queremos mas informacion de la aplicacion
wmic service where "name like 'THM Demo'" get Name,PathName
#Y con el siguiente obtenemos su process ID
Get-Process -Name thm-demo
#Para ver la informacion de red de la aplicacion
netstat -noa |findstr "LISTENING" |findstr "3212"
```