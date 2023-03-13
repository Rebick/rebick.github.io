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
