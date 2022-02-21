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
Existen diferentes maneras, aqui les mostrare 1 forma. Es necesario tener una wallet o billetera virtual, la cual almacenara nuestras criptomonedas y nos proporcionara un id publico y privado. Esto para poder mandar y recibir monedas desde esta misma wallet.


### [](#header-3)Como escoger un pool?
Estas son algunas pools populares que he visto en internet. Para escogerlas es recomendable buscar informacion y tener encuenta el como hacen sus pagos o remuneraciones por cada minado. La cantidad de impuestos que resta a la transferencia hacia tu wallet. 

>>  https://moneroocean.stream/

### [](#header-3)Donde Monitorear mi pool?


Para mi ejemplo, utilizo el siguiente pool https://moneroocean.stream/. Directamente aqui puedo consultar las ganancias que he generado y tambien visualizar los dispositivos que estan minando activamente.


##  [](#header-2)<a id="instalacion">Instalacion</a>


### [](#header-3)Instalacion en Raspberry Pi


#### [](#header-4)Materiales necesarios
*   Memoria Micro SD (64GB)
*   Raspberry Pi 3-4

#### [](#header-4)Configuracion inicial


*   Para la raspberry pi, necesitamos instalarle una version ligera de debian. Puede ser raspbian para raspberry.


Procedemos a bootear la memoria Micro SD con el programa de PyImager

~~TRUCO~~


Presionando Ctrl + x, se desplegara un menu donde podras establecer la clave de wifi y poder hacer tu configuracion remotamente desde el principio.

Podremos realizar la configuracion desde SSH predeterminadamente, da click <a>aqui</a> para mas informacion sobre la conexion remota.


```S
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


### [](#header-3)Instalacion en Android Device


*   Para el telefono android, necesitamos descargar Termux en una version mas reciente. Ya que la que esta en PlayStore, es vieja  y presenta muchos errores


#### [](#header-4)Materiales necesarios


*   Dispositivo antroid de al menos 4 GB de RAM


En seguida insertaremos los siguientes comandos:


```S
#Actualizamos el sistema
sudo su
apt update && upgrade
```


Habilitamos la conexion remota via SSH por que seguramente el telefono no sera tan comodo. 

Da click <a href='Como-establecer-una-conexion-ssh-de-calidad#android'>aqui</a>, para ir al enlace donde se explica como habilitar esta conexion en un dispositivo Android

```S
#Actualizamos el sistema
sudo su
apt update && upgrade
```


```S
#Instalacion de programa
pkg install -y git build-essential cmake

git clone https://github.com/xmrig/xmrig.git

mkdir xmrig/build && cd xmrig/build

cmake .. -DWITH_HWLOC=OFF && make -j$(nproc)

```

### [](#header-3)Instalacion en Laptop HP


## [](#header-2)<a id="">Como crear tareas programadas?</a>
En la mayoria de los servidores es necesario dejar tareas programadas, en este caso para continuar la tarea de minado una vez que el sistema presenta un error, es desconectado de la red, reiniciado o desconectado de la fuente de alimentacion electrica. Aqui podremos controlar en que momento se ejecutara algun comando. En este ejemplo editaremos en el crontab


```S
#Para ejecucion persistente
#edit crontab
crontab -e
 
#Siempre elijo usar nano, entonces daremos la opcion 
2

#paste the past command and save the file
@reboot /fullpad/./xmrig -o gulf.moneroocean.stream:10128 -u (ur Token) -p (device Name)
```


## [](#header-2)Conclusiones
Al realizar practicas como esta, se presentan continuamente errores por las nuevas actualizaciones en librerias necesarias para los programas necesarios. No desesperen en el intento por que la solucion ya la ha encontrado alguien mas y estara en un blog.
La ganancia para esta moneda es muy baja, su mantenimiento no costea la ganancia de la moneda en la actualidad. Pero el auge de las criptomonedas esta en punta y su valor podria elevarse algun dia. 
El celular que puse a minar es practicamente chatarra y espero me dure unas decadas mas trabajando para mi.

