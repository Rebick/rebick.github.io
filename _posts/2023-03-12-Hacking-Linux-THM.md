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
