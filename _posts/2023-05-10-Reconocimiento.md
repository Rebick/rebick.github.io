---
layout: post
author: Sergio Salgado
---
# [](#header-1)Reconocimiento
## [](#header-2)Indice
- <a href="#FootPrinting&Recon">FootPrinting&Recon</a>
- <a href="#networkscan">Escaneo de red</a>

## [](#header-2)<a id="FootPrinting&Recon">FootPrinting&Recon</a>

Para buscar información de algun dominio publico podemos usar el sitio de<a href="https://sitereport.netcraft.com/">netcraft</a> .
Para buscar información de algun dominio o IP publica podemos usar el sitio<a href="https://whois.domaintools.com/">domainToools</a>. Este en particular lo usé para la ubicacion de una de las tareas del CEH

Para buscar información sobre subdominios, records de algun dominio publico podemos usar el sitio<a href="https://securitytrails.com">securitytrails</a> .

Enumeracion de dominios con ng-recon
```s
recon-ng 
marketplace install all
modules search
```
Iniciamos un nuevo espacio de trabajo con:
```s
workspaces
workspaces create CEH
db insert domains certifiedhacker.com
show domains
modules load recon/somains-hosts/brute_hosts
```


```s
workspaces list
workspaces create reconnasance
modules load reacon/domains-contacts/whois_pocs
```
Listar informacion del modulo
```sinfo
options set SOURCE facebook.com
modules load recon/profiles-profiles/namechk
options set SOURCE MarkZuckerberg
run
```
```s
modules load reporting/html 
options set FILENAME /home/attacker/Desktop/Recon.html
options set CREATOR Rebick
options set CUSTOMER Mark Z
run
```
```s
modules load recon/domains-hosts/hackertarget
options set SOURCE certifiedhacker.com
```

Extrayendo informacion de un sitio usando photon
```s
python3 photon.py -h #para listar las opciones
python3 photon.py -u http://www.certifiedhacker.com 
```
El resultado es la creación de 3 archivos en la carpeta de photon  con el nombre del sitio.
El archivo external.txt contiene las urls externas que usa el sitio
El archivo internal.txt contiene las urls internas  que usa el sitio

```s
python3 photon.py -u http://www.certifiedhacker.com -l 3 -t 200 --wayback
#-l para el nivel de crawl
#-t para el numero de hilos
```
Se puede usar para clonar el sitio completo, extraer cookies usando patrones de regex

Para clonar un sitio también tenemos WinHtrack
Para encontrar información de los empleados en Linkedin podemos usar theharvester en nuestra maquina parrot:
```s
theHarvester -D eccouncil.com -l 200 -b linkedin
-D para especificar el dominio
-l para especificar el numero de resultados
-b para especificar la fuente de busqueda
```
Para encontrar información sobre un correo, podemos usar los emailheaders del correo y pasarlos a la herramienta eMailTrackerPro(emt.exe), en ella veo util que en el reporte te trae la ubicación de la IP de origen del correo

Tracerouting Windows y Linux
Esto nos servirá para ver los saltos que se tienen hacia el destino
Win
```s
tracert www.certifiedhacker.com
tracert www.certifiedhacker.com -h 5
```
La opcion -h listará solo los 5 saltos que se den

Lin
```s
traceroute www.certifiedhacker.com
```


# [](#header-1)<a id="networkscan">Escaneo de redes</a>
Usando nmap, podemos primero usar 
```s
nmap -sn -PR 10.10.1.22
```
Los parametros 
-sn (Para no hacer escaneo de puertos)
-PR (P para hacer ping, R para escaneo ARP)

Otra opcion para escaneo UDP
```s
nmap -sn -PU 10.10.1.22
```

Otra opcion para escaneo de Echo request e ICMP
```s
nmap -sn -PE 10.10.1.22
```
Otra opcion para escaneo de Echo request e ICMP a un rango de IPs
```s
nmap -sn -PE 10.10.1.22
```
Otra opcion para escaneo de Timestamp request 
```s
nmap -sn -PP 10.10.1.22
```
Otra opcion para escaneo de Netmask request 
```s
nmap -sn -PM 10.10.1.22
```

Otra opcion para escaneo de servicios TCP SYN/ACK, PO para raw sockets
```s
nmap -sn -PS 10.10.1.22
nmap -sn -PA 10.10.1.22
nmap -sn -PO 10.10.1.22
```

La opcion -sT especifica el escaneo por TCP o por UDP con la opcion Uy la -v el output en verbose 
```s
nmap -sT -v 10.10.1.22
nmap -sU -v 10.10.1.22
```
La opcion -sS especifica el escaneo por SYN (Antes de hacer el handshake, esto ayudaría a ver los puertos abiertos aunque el servidor tenga habilitado el firewall)
```s
nmap -sS -v 10.10.1.22
#De acuerdo a los ejercicios, me es util saber que puertos son los que están abiertos, en este caso hemos hecho el filtro hasta este punto
target="172.16.0.1-255" && nmap -sS $target | grep -v "host down" | grep "Discovered open port" | sed -e 's/Discovered open port //g' -e 's/ on / <-SYN-> /g' | sort -t' ' -k3,3
```
La opcion -sX especifica el escaneo Christmas Tree(El Christmas scan envía paquetes TCP con las banderas FIN, PSH y URG activadas a los puertos del objetivo.) 
Maimon con la opcion M (El Maimon scan es un tipo de escaneo que envía paquetes TCP con las banderas FIN y ACK activadas.)
A escaneará con la bandera ASK activa(Este escaneo envía paquetes TCP con solo la bandera ACK activada)
```s
nmap -sX -v 10.10.1.22
nmap -sM -v 10.10.1.22
nmap -sA -v 10.10.1.22
```
La opcion -sV especifica la version del servicio
```s
nmap -sV -v 10.10.1.22
```

Ahora crearemos un perfil para escanear la red, con zenmap usaremos el perfil Intense scan o en este caso, crearemos un perfil en la pestaña de profile. 
El nombre será Null profile y el comando a ejecutar es:
```s
nmap -sN -T4 -A -v
```
NSE(nmap script engine)
A partir de ahora usaremos los scripts de nmap para determinar mejorar la eficicencia del escaneo.
El primer ejemplo, mediante smb determinaremos el sistema operativo
```s
nmap --script=smb-os-discovery.nse 10.10.1.22
```

Agregando la opcion -D IP1,IP2,ME, podemos confundir a la victima haciendo pasar el escaneo por diferentes tipos de IP de origen. Se pueden usar IPs aleatorias si se pone la variable RND. Quedaría de la siguiente forma:
```s
sudo nmap -sS -Pn -F -D RND,RND,ME,RND,RND $IP
```

Tambien se puede usar de la forma:
```s
sudo nmap -sS -Pn -F -D RND:3 $IP
```

Tambien se puede spoofear la MAC Address con el comando --spoof-mac 00:02:DC, esto solo funcionaria en caso de que se comparta el mismo segmento de red con la MAC especificada y así poder capturar los paquetes de destino hacia este
Para hacer spoof de la IP tenemos el comando -S $IP y también sirve solo si estamos en el mismo segmento de red.

Para usar puertos que quizas sean permitidos solamente en la red, podemos especificarle a nmap que lo use para realizar el escaneo, de la forma siguiente
```s
nmap -sS -Pn -g 8080 -F MACHINE_IP 
nmap -sS -Pn --source-port 8080 -F MACHINE_IP
```

Fragmentación de paquetes con 8 bytes de data.
Una de las formas sencillas de realizarlo es con la opción "-f" de nmap, ya que si se ejecuta de manera predeterminada, se mandará con 24 bytes. 
```s
nmap -sS -Pn -f -F MACHINE_IP
```

La misma fragmentación, pero con 16 bytes de data es posible tambien agregando una f al comando anterior, para que quede de la manera siguiente:
```s
nmap -sS -Pn -f -F MACHINE_IP
```

Fragmentación de paquetes de acuerdo estableciendo una unidad maxima de transmision (MTU)
al comando se le agrega la opción "--mtu $VALUE", el cual especifica el numero de bytes por paquete de IP. En otras palabras el tamaño del encabezaado de la IP no viene incluido. Este valor deberá ser siempre un múltiplo de 8.
```s
nmap -sS -Pn --mtu 8 -F MACHINE_IP
```

Generacion de paquetes con tamaño especifico.
Es posible ser más evasivos contra un IDS o IPS estableciendo un tamaño especifico de paquetes. Con nmap, la opcion es "--data-length $VALUE" y nuevamente $VALUE deberá ser un multiplo de 8.
```s
nmap -sS -Pn --data-length 64 -F MACHINE_IP
```

Especificando ttl
nmap nos da más controles sobre la modificacion de los encabezados de IP. Unos de estos campos que se pueden controlar son los TTL. La opcion es "--ttl $VALUE", esta opcion es util si piensas que tu ttl de default expone actividad de escaneo de puertos.
```s
nmap -sS -Pn --ttl 81 -F MACHINE_IP
```

Usando una checksum erronea
Algunos sistemas tiran los paquetes al contenerse una erronea chcksum, la opcion en nmap es: "--badsum".
```s
nmap -sS -Pn --badsum -F MACHINE_I
```

Comando final a intentar
```s
nmap -sS -Pn --badsum -F 
```

Script automatizado para extraer los puertos hallados
```s
target=10.10.10.245 && ports=$(nmap -p- --min-rate=1000 -Pn -T4 $target | grep '^[0-9]' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//) &&
nmap -p$ports -Pn -sC -sV $target
```
Script automatizado para detección de puertos (SYN, XMAS)
```s
#!/bin/bash

# Verificar si se ha proporcionado un objetivo
if [ -z "$1" ]; then
  echo "Uso: $0 <target>"
  exit 1
fi

# Define the target
target=$1

# Function to run nmap scan and process results
run_scan() {
  local scan_type=$1
  local flag=$2
  local label=$3
  
  echo "Running $scan_type scan..."
  nmap $flag $target -v | grep -v "host down" | grep "Discovered open port" | sed -e 's/Discovered open port //g' -e "s/ on / $label /g" | sort -t' ' -k3,3
  echo "$scan_type scan complete."
  echo
}

# Run the SYN scan
run_scan "SYN" "-sS" "<-SYN->"

# Run the XMAS scan
run_scan "XMAS" "-sX" "<-XMAS->"

# Run the MAIMON scan
run_scan "MAIMON" "-sM" "<-MAIMON->"

# Run the ACK scan
run_scan "ACK" "-sA" "<-ACK->"

echo "All scans complete."


```
Escaneo con hping3
Esta herramienta nos ayuda a escanear bajo un IDS o Firewall, en el primer ejemplo tenemos un escaneo por UDP, usando mac diferentes
```s
hping3 10.10.1.11 --udp --rand-source --data 500
```
En el segundo ejemplo ejecutaremos un comando mediante conexion SYN, con 5 paquetes a enviar
```s
hping3 10.10.1.11 -S -p 80 -c 5
```
En el tercer ejemplo, realiza un ataque de inundación de paquetes sin recibir o esperar respuesta
```s
hping3 10.10.1.11 --flood
```

Escaneo con metasploit framework
```s
msfconsole
msf6>nmap -Pn -sS -A -oX Test 10.10.1.0/24
msf6>db_import Test
msf6>hosts #lista los hosts OS,, IPs, Mac
msf6>services #lista de los servicios de los host activos
msf6>
msf6>search portscan
msf6>use auxiliary/scanner/portscan/syn
msf6 auxiliary(scanner/portscan/syn)>set INTERFACE eth0
msf6 auxiliary(scanner/portscan/syn)>set PORTS 80
msf6 auxiliary(scanner/portscan/syn)>set RHOSTS 10.10.1.5-23
msf6 auxiliary(scanner/portscan/syn)>set THREADS 50
msf6 auxiliary(scanner/portscan/syn)>run

msf6>use auxiliary/scanner/portscan/tcp
msf6 auxiliary(scanner/portscan/tcp)>set RHOSTS 10.10.1.5-23
msf6 auxiliary(scanner/portscan/tcp)>run

msf6>use auxiliary/scanner/smb/smb_version
msf6 (scanner/smb/smb_version)>set RHOSTS 10.10.1.5-23
msf6 (scanner/smb/smb_version)>set THREADS 11
```
Existen otros modulos para usar como el modulo de ftp para determinar el sistema operativo del sistema.

Attack Surface
Consta de los siguientes pasos importantes
Extraccion de subdominios

```s
#Este comando, tiene como objetivo extraer los subdominios up y down del objetivo, esto mediante subfinder y un ping.
#El uso es tener un archivo llamado target y despues proporcionar el comando siguiente
sudo subfinder -silent -all -dL target | xargs -I{} sh -c 'ping -c 1 {} > /dev/null && echo {} >> subdominios_up || echo {} >> subdominios_down'
#Despues si queremos contabilizar los resultados, podemos usar el siguiente comando
cat subdominios_up | wc -l 
#Para ver rapido que tecnologias usa, tenemos whatweb
whatweb $(cat subdominios_up)
```
Para automatizar el uso de httpx tenemos
```s
#!/bin/bash

# Verificar si se proporcionó un archivo como argumento
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <archivo>"
    exit 1
fi

archivo="$1"

# Verificar si el archivo existe
if [ ! -f "$archivo" ]; then
    echo "El archivo $archivo no existe."
    exit 1
fi

# Contar respuestas por tipo
count_20x=$(grep -E "20[0-9]" "$archivo" | wc -l)
count_30x=$(grep -E "30[0-9]" "$archivo" | wc -l)
count_40x=$(grep -E "40[0-9]" "$archivo" | wc -l)

# Mostrar resultados
echo "Resumen de códigos de respuesta:"
echo "20X: $count_20x"
echo "30X: $count_30x"
echo "40X: $count_40x"
```

Analisis de vulnerabilidades
Con nikto tenemos el siguiente comando

```s
while read -r line; do nikto -h $line -o $line.txt; done < subdominios_up
```