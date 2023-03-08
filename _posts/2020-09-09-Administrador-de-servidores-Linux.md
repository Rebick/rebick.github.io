---
layout: post
author: Sergio Salgado
---

## [](#header-2)<a id="usuarios">Los usuarios</a>

Para crear usuarios, tenemos 2 comandos especiales, uno es: 

```S
#Este primero lo crea sin contrasena
 useradd
#Este segundo lo crea con contrasena
 adduser
 ```

Para borrar alguno solamente basta con hacer un

userdel

Para conocer los permisos con los que cuenta el usuario, esta el comando 

```s
sudo -l
```

## [](#header-2)NGNIX, WAF

Hablando de seguridad, existe una actividad de laboratorio interesante, la cual consiste en el uso de un servidor web vulnerable, eneste caso WebGOAT de OWASP y con un WAF a continuacion mencionare algunos, protegere este servicio vulnerable. Asi detectaremos ataques de SQL, XSS y un poco mas. 
Estos ejercicios los realizare en mi raspberry para administrarla correctamente y poder presentar los proyectos en ella propiamente.

Como estos servicios pueden estar corriendo en el mismo puerto, podemos empezar

Para validar los puertos que tienen un proceso activo usamos:

```s
sudo netstat -tulpn
```

Lo primero sera la instalacion de ngnix y el waf

```s
sudo apt install nginx nginx-extras libcurl4-openssl-dev
```

En otro servidor instalare webGOAT
Instalamos sus dependencias

```s
sudo apt install apache2 maven openjdk-17-jdk openjdk-17-jre
```
Si se siguió el orden de instalación, NGINX no debe estar ejecutándose, pues por defecto intentará levantarse en el puerto 80, el cual ya se encuentra ocupado por WebGOAT, para ello cambiaremos el puerto de WebGOAT al puerto alterno http 8080.

## [](#header-2)NMAP protips

Es posible pasarle a nmap una lista de hosts a escanear, y el comando es:

```s
nmap -iL list_of_hosts.txt
```

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
