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

## [](#header-2)<a id="explotacion">Explotacion</a>

## [](#header-2)<a id="hardening">Hardening</a>
Esta parte quedara pendiente...