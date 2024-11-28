---
layout: post
author: Sergio Salgado
---

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#Search_Engine">Search Engine</a>
- <a href="#Search_Engine_tools">Herramientas de Search Engine</a>

## [](#header-2)<a id="introduccion">Introduccion</a>

Para esta tecnica, la palabra clave es el crawling; que como un gusano programado, se encarga de navegar un sitio y extenderse a traves de el en busca de keywords (mas sencillo que elaborar una wordlist). En esta ocacion, para mejorar sus resultados de busqueda, google conoce las palabras clave de las paginas publicas, tambien sabe los documentos que conforman la pagina; entonces nosotros podremos hacerle consultas mas especificas sobre el material con el que queremos trabajar.
En este post, mostrare ejemplos de la academia de tryhackme.com

## [](#header-2)<a id="Search_Engine">Search Engine</a>
Como ver la calificacion de el motor de busqueda que asigna google? 
Para esto podemos usar: <a href="https://pagespeed.web.dev">Google Site's Analyzer</a>

Que archivos son importantes en un sitio?
En la ruta raiz normalmente se encuentra el archivo site.xml que es el mapa del sitio, y el otro archivo importante que podemos encontrar es el robots.txt que es el archivo que permitira a los navegadores indexar el sitio con sus crawlers.

Los comandos son:

|:---|:-----------------------|:-----------------|
| #  |      **Termino**       |     **Accion**   |
|:---|:-----------------------|:-----------------|
| 1  | filetype:              | Busca el archivo por su extension |
|:---|:-----------------------|:-----------------|
| 2  | cache:                 | Ver la version en cache de Google de una URL especifica |
|:---|:-----------------------|:-----------------|
| 3  | intitle:               | La frase especifica debera estar en el titulo de la pagina |
|:---|:-----------------------|:-----------------|
| 4  | inurl:               | La frase especifica debera estar en la URL |
|:---|:-----------------------|:-----------------|
| 5  | :ftp              | Se puede usar para encontrar hasta servidores ftp ejemplo: shakespeare:ftp |
|:---|:-----------------------|:-----------------|
| 6  | :link              | Lista las paginas que tienen el link del sitio presente |
|:---|:-----------------------|:-----------------|
| 7  | :related              | Lista las paginas que son similares al sitio |
|:---|:-----------------------|:-----------------|
| 8  | :info              | Presenta informacion que tenga google sobre el sitio |
|:---|:-----------------------|:-----------------|
| 9  | :allintitle              | Restringe el resultado a sitios que contengan el keyword en el titulo |
|:---|:-----------------------|:-----------------|
| 10 | :allinurl              | Restringe el resultado a sitios que contengan el keyword en la URL |
|:---|:-----------------------|:-----------------|
| 11 | :location              | Encuentra informacion en una ubicacion en especifico |
|:---|:-----------------------|:-----------------|

Ejemplos:
Para encontrar paginas con portales de login_
inurl:"/sslvpn_logon.shtml" intitle:"User Authentication" "WatchGuard Technologies"

Para encontrar portales de Logins de VPN
inurl:/sslvpn/Login/Login
ó
site:vpn.*.*/ intitle:"login"
ó
site:vpn.*.*/ intext:"login" intitle:"login"

Para encontrar paginas de login de VPN de Fortinet
intext:Please Login SSL VPN inurl:remote/login
intext:FortiClient

Para encontrar informacion sensible o jugosa
intitle:"index of" /etc/openvpn/

Encontrar llaves estaticas de openvpn
"-----BEGIN OpenVPN Static key V1----" ext:key

Para extraer la informacion de configuracion de vpn
initle:"index of" "vpn-config.*"

Encontrar archivos de configuracion de openVPN, certificados y llaves
Index of *.ovpn

Encontrar portales de login para Nescaler y Citrix Gateway VPN
inurl:"/vpn/tmindex.html" vpn

Encontrar portales de login de Cisco ASA
intitle:"SSL VPN Service" + intext:"Your system administrator provided the following information to help understand and remedy the secrity conditions:"

## [](#header-2)<a id="Search_Engine_tools">Search Engine Tools</a>
Existen herramientas para este reconocimiento ademas de una search engine con Google o Bing.
Herramientas como:
- 
- <a href="https://www.netcraft.com">netcraft</a>, la cual puede usarse desde la version web o utilidades de linea de comando
- Sublist3r
##[](#header-2)<a id="DNS_enumeration">Enumeracion por DNS</a>

El comando siguiente buscara por un rango de IPs las conicidencias por dns disponibles

```s
for ip in $(seq 185 254); do host 201.131.44.$ip; done | grep -v "not found"
```