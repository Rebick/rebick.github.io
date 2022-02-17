---
layout: post
author: Sergio Salgado
---

# [](#header-1)Como minar criptomonedas con Monero?

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#about_monero">Que es Monero?</a>
- <a href="#instalacion">Instalacion</a>
  - <a href="raspberry">Raspberry Pi</a>
  - <a href="android">Android Device</a>
  - <a href="linux">Linux PC</a>
- <a href="#conclusiones">Conclusiones</a>

## [](#header-2)<a id="introduccion">Introduccion</a>

## [](#header-2)<a id="about_monero">Que es Monero?</a>
**Monero** es una divisa en las criptomonedas en la que el minado de los bloques se divide entre dispositivos para ser procesados. No como en _bitcoin_ que tienes que minar el bloque completo para poder minar correctamente la moneda. Por lo tanto esta criptomoneda *Monero* es posible minarla hasta con dispositivos cuyo procesamiento es relativamente bajo. Como podria ser un telefono con 4 GB de RAM o una RaspBerry Pi 4 B cpn 4 GB de RAM.


### [](#header-3)Como unirme a monero?
Existen diferentes maneras, aqui les mostrare 1 forma. Para usuarios de Linux y Windows. 
### [](#header-3)Como escoger un pool?

##  [](#header-2)<a id="instalacion">Instalacion</a>
### [](#header-3)Instalacion en Raspberry Pi
#### [](#header-4)Materiales necesarios
*   Memoria Micro SD (64GB)
*   Raspberry Pi 3-4

#### [](#header-4)Configuracion inicial
Para la raspberry pi, necesitamos instalarle una version ligera de debian. Puede ser la version .
Una vez finalizada y <a href='/Como-verificar-descargas-mediante-hash'>verificada</a> la descarga


Procedemos a bootear la memoria Micro SD con el programa de PyImager

~~TRUCO~~
Presionando Ctrl + x, se desplegara un menu donde podras establecer la clave de wifi y poder hacer tu configuracion remotamente desde el principio.
```cmd
#UPDATE SYSTEM
sudo su
apt update && upgrade

#INSTALL BASSIC LIBRARIES
sudo apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev -y

#GIT REPO
git clone https://github.com/xmrig/xmrig.git

#Intro the following commands
cd xmring
mkdir build
cd build

cmake ..
make

#RUN
./xmrig -o gulf.moneroocean.stream:10128 -u 42QDcj2MY7FTEdu2VfSJnT14o7iqtmGSfN6rzd7WgiAacx8eLwkSmrNfooKXU1Q7w2d9zpAB9bndSAe32T5CxLAqUzgqJdW -p rebickComp1
```
~~TIP~~
```cmd
#Para ejecucion persistente
#edit crontab
crontab -e

#paste the past command and save the file
@reboot /fullpad/./xmrig -o gulf.moneroocean.stream:10128 -u (ur Token) -p rebickComp1
```
## [](#header-2)Instalacion en Android Device
Primero tenemos que descargar la aplicacion Termux desde la Play Store.
En seguida insertaremos los siguientes comandos:
```
#Actualizamos el sistema
sudo su
apt update && upgrade
```

Habilitamos la conexion remota via SSH por que seguramente el telefono no sera tan comodo.

```
pkg upgrade
pkg install openssh
```

Por default la contrasena esta establecida, por lo que ingresaremos a verla con
PrintMotd yes
PasswordAuthentication yes
Subsystem sftp /data/data/com.termux/files/usr/libexec/sftp-server

Para ver tu usuario
```
$ whoami
```

Para establecer una nueva contrasena

```
$ passwd
New password:
Retype new password:
New password was successfully set.

```

Lado de la computadora

```
#Actualizamos el sistema
sudo su
apt update && upgrade
#Instalacion de openssh
apt install openssh
#Para loggearte en una maquina con ssh en ejecusion donde el puerto por default es (22):
ssh user@hostname_or_ip
```
```
#Para usar un puerto en especifico
ssh -p 8022 user@hostname_or_ip

#Para uso de llave privada y publica
ssh -i id_rsa user@hostname_or_ip

#Instalacion de programa
pkg install -y git build-essential cmake

git clone https://github.com/xmrig/xmrig.git

mkdir xmrig/build && cd xmrig/build

cmake .. -DWITH_HWLOC=OFF && make -j$(nproc)

### [](#header-3)Instalacion en Laptop HP
```

```
Long, single-line code blocks should not wrap. They should horizontally scroll if they are too long. This line should be long enough to demonstrate this.
```

### [](#header-2)Donde Monitorear mi pool?

## [](#header-2)Conclusiones
Al realizar practicas como esta, se presentan continuamente errores por las nuevas actualizaciones en librerias necesarias para los programas necesarios. No desesperen en el intento por que la solucion ya la ha encontrado alguien mas y estara en un blog.
La ganancia para esta moneda es muy baja, su mantenimiento no costea la ganancia de la moneda en la actualidad. Pero el auge de las criptomonedas esta en punta y su valor podria elevarse algun dia. 
El celular que puse a minar es practicamente chatarra y espero me dure unas decadas mas trabajando para mi.

