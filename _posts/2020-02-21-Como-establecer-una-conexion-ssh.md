---
layout: post
author: Sergio Salgado
---

# [](#header-1)Como establecer una conexion remota SSH?

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#about_ssh">Que es SSH?</a>
- <a href="#instalacion">Instalacion</a>
- <a href="#configuracion">Configuracion</a>
- <a href="#conexion">Establecer conexion</a>
- <a href="#conclusiones">Conclusiones</a>

## [](#header-2)<a id="introduccion">Introduccion</a>
Es incomodo utilizar la terminal desde algunos dispositivos, o simplemente la interfaz no es como a la que estamos acostumbrados. En este post mostrare como configurar correctamente el servicio de SSH para poder establecer una conexion remota desde otro dispositivo.


## [](#header-2)<a id="about_ssh">Que es SSH?</a>


## [](#header-2)<a id="about_ssh">Instalacion</a>


Para dispositivos con sistema operativo basado en debian


```S
#Actualizacion de sistema
sudo apt update && upgrade
#Instalacion de openssh
apt install openssh
#Para loggearte en una maquina con ssh en ejecusion donde el puerto por default es (22):
ssh user@hostname_or_ip
```


Para dispositivos <a id="andorid">android</a>


```S
pkg upgrade
pkg install openssh
```

## [](#header-2)<a id="about_ssh">Configuracion</a>

Por default la contrasena esta establecida, por lo que ingresaremos a verla con
PrintMotd yes
PasswordAuthentication yes
Subsystem sftp /data/data/com.termux/files/usr/libexec/sftp-server

Para establecer una nueva contrasena


```S
$ passwd
New password:
Retype new password:
New password was successfully set.

```

## [](#header-2)<a id="conexion">Establecer conexion</a>
Para saber el usuario de la maquina donde nos conectaremos

```S
$ whoami
```


```S
#Para usar un puerto en especifico
ssh -p 8022 user@hostname_or_ip
```

Tambien es posible crear en la maquina servifor un archivo dentro de /.ssh/ que se llame authorized_keys, jabra que copiarle la llave privada y asignarle el codigo de permisos 600. La llave se copia dentro de algun directorio de la maquina que se conectara con el nombre de id_rsa y se le pasara el siguiente comando:

```s
#Para uso de llave privada y publica
ssh -i id_rsa user@hostname_or_ip
```



## [](#header-2)<a id="conclusiones">Conclusiones</a>
Es necesario utilizar muchos dispositivos para alguien que se dedica a la tecnologia, por lo que lo mas practico seria utilizar solo una maquina para poder comunicarnos entre los dispositivos y poder configurarlos.