---
layout: post
author: Sergio Salgado
---

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#reconocimiento">Reconocimiento</a>
- <a href="#enumeracion">Enumeracion</a>
- <a href="#explotacion">Explotacion</a>
- <a href="#hardening">Hardening</a>

## [](#header-2)<a id="introduccion">Introduccion</a>
Un analisis de vulnerabilidades exitoso consiste en desarrollar una metodologia util para su ejecucion, en este post el objetivo es plasmar las herramientas vistas en el Libro Hacking Exposed Windows; a su vez actualizare la manera que se puede usar las herramientas desde kali Linux 2022 y tambien poner en que maquinas se ha utilizado en HtB para poder ejemplificar de manera correcta dichas acciones.

## [](#header-2)<a id="reconocimiento">Reconocimiento</a>

La primera herramienta seria ver como responde el DNS del objetivo con la herramienta whois, que viene instalada en Kali predeterminadamente

```s
whois 192.168.30.15
```

Si el objetivo esta expuesto a la red, podemos emplear OSINT con Shodan, Google, etc.

Podemos hacer un banner grabbing con netcan de la manera siguiente:

```s
nc -vv server 80
```

Para obtener el sistema operativo base, bastara con un ping. Los paquetes ttl 64 significa que es linux y 128 significara que nos presentamos ante una Windows

Con nmap podemos tambien descubrir equipos aledanos o puertos expuestos, *hay que tener en cuenta que este escaneo es muy ruidoso y se puede bloquear la conexion* los comandos que suelo utilizar son:

```s
#Para descurbir mas hosts
sudo nmap 10.10.11.170/24

#Escaneo rapido
sudo nmap -p- --open -sS --min-rate 5000 -vvv 10.10.11.170

#Escaneo rapido con informacion de los puertos
sudo nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn 10.10.11.170 -oG allPorts

#Escaneo sobre los puertos descubirtos
sudo nmap -sCV -p22,8080 10.10.11.170 -oN targeted

#Escaneo sobre UDP
sudo nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn 10.10.11.116
```

## [](#header-2)<a id="enumeracion">Enumeracion</a>
Para tener un enfoque mas atinado, necesitamos tener una idea de que servicios son los que se descuidan en su configuracion normalmente. 

Los servicios de Windows tipicamente atacados son:
|:---|:-----------------------|:-------|
| #  |        **Name**        | **PORT** |
|:---|:-----------------------|:-------|
| 1  | DNS zone transfer| 53  |
|:---|:-----------------------|:-------|
| 2  | Microsoft RPC| 135  |
|:---|:-----------------------|:-------|
| 3  | NetBIOS Name Service (NBNS)| 137  |
|:---|:-----------------------|:-------|
| 4  | NetBIOS session service (SMB over NetBIOS)| 139  |
|:---|:-----------------------|:-------|
| 5  | SMB over TCP (Direct Host)| 445  |
|:---|:-----------------------|:-------|
| 6  | Simple Network Management Protocol (SNMP)| 161  |
|:---|:-----------------------|:-------|
| 7  | Lightweight Directory Access Protocol (LDAP)| 389  |
|:---|:-----------------------|:-------|
| 8  |Global Catalog Service| 3268  |
|:---|:-----------------------|:-------|
| 9  | Terminal Services| 3389  |
|:---|:-----------------------|:-------|

### [](#header-3)<a id="netbios_enum">Enumeracion de NETBIOS</a>
El primer paso, sera descubrir si existe un dominio presente, este escaneo es pasivo y el comando a ejecutar desde una maquina windows seria:

```s
C:\>net view /domain
```

## [](#header-2)<a id="Breaching_ad">Breaching Active Directory</a>
NTLM Authenticated Services
New Technology LAN Manager (NTLM). Es el modo de autenticacion usado por varias tecnologias integradas en el AD, como Mail (Outlook Web App), accesos a RDP expuestos a internet, VPN que son integradas con AD, aplicaciones web que hacen uso de NetNTLM.
+(SOC protip) Este tipo de ataques se pueden detectar via multiples inicios de sesion fallidos que contienen el codigo 4265
Juega el rol de hombre en medio entre el cliente y el AD, Resolviendo un reto que solamente con la contraseña correcta se resolverá
-TEST
Brute-force Login Attacks
Password Spraying

LDAP Bind Credentials
Otro metodo de autenticación del AD es la autenticacion Lightweight Directory Access Protocol (LDAP). Es similar a la autenticación NTLM. Solamente que con este metodo, las credenciales de usuario se verifican directamente. La aplicacion usa primero un par de contraseñas que tiene para LDAP y despues verificar el usuario de AD.
Su uso es popular en aplicaciones como: Gitlab, Jenkins, Custom-developed web applications, Printers, VPNs.
Es posible usar los mismos ataques que se usaron en NTLM. Si se obtiene acceso a un servidor de Gitlab por ejemplo, podría ser posible obtener las credenciales de AD, ya que normalmente se almacenan en texto plano.
-TEST
LDAP Pass-back Attacks
Cuando se obtiene acceso a la red local o a la aplicacion web. Redirigiendo la autenticacion a nuestro dispositivo maligno podremos interceptar estas credenciales de LDAP.
Para realizar este ataque, usaremos 
```s
sudo apt-get update && sudo apt-get -y install slapd ldap-utils && sudo systemctl enable slapd
sudo dpkg-reconfigure -p low slapd
```

La configuracion de nuestro servidor LDAP tendrá vulnerabilidades para obligar a que se compartan las claves en texto plano.

```s         
#Nombre del archivo: olcSaslSecProps.ldif
dn: cn=config
replace: olcSaslSecProps
olcSaslSecProps: noanonymous,minssf=0,passcred

    olcSaslSecProps: Specifies the SASL security properties
    noanonymous: Disables mechanisms that support anonymous login
    minssf: Specifies the minimum acceptable security strength with 0, meaning no protection.
```

Para inciarlo  ejecutamos el comando
```s
sudo ldapmodify -Y EXTERNAL -H ldapi:// -f ./olcSaslSecProps.ldif && sudo service slapd restart
```

Para probar su funcionamiento:
```s
ldapsearch -H ldap:// -x -LLL -s base -b "" supportedSASLMechanisms
```

Una vez configurado correctamente, podemos obtener las credenciales con un
```s
sudo tcpdump -SX -i breachad tcp port 389
```

Authentication Relays
Continuando con los metodos de autenticación, existen numerosos servicios que hablan entre si para permitir a los usuarios el uso de los mismos. En esta ocacion veremos el servicio de SMB (Server Message Block) el cual permite a los clientes como workstations comunicarse con el servidor.
-TEST
Intercepting NetNTLM Challenge
En esta parte usaremos un programa que se llama responder, el cual interceptará el reto NetNTLM para crackearlo, ya que usualmente hay demasiados packetes de estos sobre la red. En un entorno normal, responder puede envenenar cualquier peticion de Link-Local Multicast Name Resolution (LLMNR), NetBIOS Name Service (NBT-NS) o Web Proxy Auto-Discovery (WPAD). Responder se encuentra en el  <a href=" https://github.com/lgandx/Responder">link</a>.
Su forma de uso será:
```s
sudo responder -I tun0
```

Una vez obtenido el archivo NTLMv2-SSP Hash, podemos crackear las contraseñas con
```s
hashcat -m 5600 <hash file> <password file> --force
```

Relaying the Challenge (Reenvio del reto)
Para poder reenviar este ataque, se tienen que cumplir varias condiciones que se obtienen con la enumeración de los activos:
1. El firmado por SMB debera estar deshabilitado o habilitado, pero no reforzado. 
2. La cuenta asociada deberá contar con los permisos necesarios para acceder a los recursos solicitados.

Microsoft Deployment Toolkit
En las organizaciones no se debería tener a los empleados de TI portar USBs y DVDs para instalar programas, para eso usarían herramientas como el Developer Kit y es aquí donde explotaremos las vulnerabilidades que este tipo de soluciones contienen. 
Microsoft Deployment Toolkit (MDT) nos ayudará a mantener las imagenes del OS en una ubicacion centralizada y actualizada; normalmente esta herramienta está integrada con Microsoft Deployment Toolkit (MDT), quien gestiona las actualizaciones de Microsoft.
En este ejemplo se tomará en cuenta Preboot Execution Environment (PXE) boot.
El archivo normalmente se encuentra en la carpeta TMP. Y podemos acceder a el con la <a href="https://github.com/wavestone-cdt/powerpxe">herramienta</a> , o con powershell:
```s
C:\Users\THM\Documents\Am0> powershell -executionpolicy bypass
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.   

PS C:\Users\THM\Documents\am0> Import-Module .\PowerPXE.ps1
PS C:\Users\THM\Documents\am0> $BCDFile = "conf.bcd"
PS C:\Users\THM\Documents\am0> Get-WimFile -bcdFile $BCDFile
>> Parse the BCD file: conf.bcd
>>>> Identify wim file : <PXE Boot Image Location>
<PXE Boot Image Location>
```

Nuestro objetivo será encontrar un archivo llamado bootstrap.ini y ahi estarán las credenciales de acceso a AD.
Para mas informacion sobre este ataque, visitemos el link <a href="https://www.riskinsight-wavestone.com/en/2020/01/taking-over-windows-workstations-pxe-laps">herramienta</a> 

Configuration Files
La última enumeracion posible que exploraremos son los archivos de configuración. En dado caso de que podamos acceder a una maquina, podremos recuperar las credenciales de AD, dependiendo del proposito del host, podremos encontrar estas en diferentes lugares como: Archivos de configuracion de Aplicaciones Web,  Archivos de configuracion de servicios, Llaves de registro, Apliaciones desplegadas centralmente. Existen herramientas para enumerar este ataque como <a href="https://github.com/GhostPack/Seatbelt">Seatbelt</a> 


## [](#header-2)<a id="Enumerating_ad">Enumerating Active Directory</a>
En esta parte se explicará la herramienta binaria llamada runas.exe.
Si alguna vez haz tenido credenciales de AD, pero no haz podido logearte con ellas, esta es la solucion. Si tenemos las credenciales de AD en el formato :, podremos usar Runas, un comando comun de runas.exe luce como:
```s
runas.exe /netonly /user:<domain>\<username> cmd.exe
```

Let's look at the parameters:

    /netonly - Since we are not domain-joined, we want to load the credentials for network authentication but not authenticate against a domain controller. So commands executed locally on the computer will run in the context of your standard Windows account, but any network connections will occur using the account specified here.
    /user - Here, we provide the details of the domain and the username. It is always a safe bet to use the Fully Qualified Domain Name (FQDN) instead of just the NetBIOS name of the domain since this will help with resolution.
    cmd.exe - This is the program we want to execute once the credentials are injected. This can be changed to anything, but the safest bet is cmd.exe since you can then use that to launch whatever you want, with the credentials injected.

Una vez dentro del sistema, podemos listar los Volumenes, uno de los mas comunes en listar es el SYSVOL, el cual almacena las GPOs e informacion relacionada con el dominio.
*Antes de empezar a listar el SYSVOL*, es necesario configurar el DNS, con lo siguiente:
```s
$dnsip = "<DC IP>"
$index = Get-NetAdapter -Name 'Ethernet' | Select-Object -ExpandProperty 'ifIndex'
Set-DnsClientServerAddress -InterfaceIndex $index -ServerAddresses $dnsip
```

ADVMonitoreoIP vs Hostnames
Existe una pequeña diferencia entre los comandos 
```s
dir \\za.tryhackme.com\SYSVOL 
dir \\<DC IP>\SYSVOL
```
Mientras que con el primer ejemplo podemos forazar a que se realice una autenticación mediante kerberos, con el segundo podemos forzar una autenticación NTLM.
