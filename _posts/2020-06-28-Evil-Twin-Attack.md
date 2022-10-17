---
layout: post
author: Sergio Salgado
published: false
---

## [](#header-2)Introduccion

Existen herramientas como ncrack, airmon-ng,aircrack-ng, y demas de la familia ng. Esto para obtener las contrasenas de las redes WiFi con seguridad WPS o WPA, pero ahora en su nuevo protocolo de WPA2 se vuelve mas complicado por que se implementa ahora una nueva capa de seguridad en la que es posible actualizar los dispositivos para evitar que sean vulnerados. Tambien existen Routers o Access Points capaces de mitigar el ataque que a continuacion veremos. 

## [](#header-2)Teoria

La teoria de como se pueden vulnerar estas redes es simple, en primera los APs siempre estan en escucha preguntando que dispositivos estan conectados, cuando un dispositivo intenta establecer una conexion con un Punto de Acceso se manda la contrasena encriptada o como se llama comunmente (Handshake), el cual tiene una dificultad de crackeado alta y mas si la contrasena es robusta y extrana; para esto esta un metodo de ingenieria social llamado `Evil Twin Attack`. 
Su funcionamiento es sencillo, se copia el nombre del punto de acceso y a la interfaz se le puede asignar el mismo MAC Address, se tiene que levantar un servicio que parezca un portal donde se pida la clave, similar al de los centros comerciales o en starbucks, y como duenos del portal podremos ver todo lo que se reciba.

## [](#header-2)Desarrollo

Para este caso, usaremos una herramienta que integra todo lo anterior, agiliza y facilita totalmente el ataque y a continuacion se explicara como usarlo.

### [](#header-3)Herramientas para el laboratorio

- Antena con capcidad de modo monitor(Se usara una <a href="https://www.amazon.com.mx/Alfa-Dual-Band-inal%C3%A1mbrico-Adaptador-externas/dp/B00VEEBOPG/ref=asc_df_B00VEEBOPG/?tag=gledskshopmx-20&linkCode=df0&hvadid=295455832799&hvpos=&hvnetw=g&hvrand=13944828763802666103&hvpone=&hvptwo=&hvqmt=&hvdev=c&hvdvcmdl=&hvlocint=&hvlocphy=1010043&hvtargid=pla-406165012713&psc=1"> Alpha rtl8812au</a> para este ejercicio) 

![Antena](/assets/images/EvilTwin/alpha.jpeg)

- Maquina con OS Kali o Parrot

### [](#header-3)Configuracion de Antena

La antena tambien debera ser configurada correctamente para que funcione bien y podemos usarla posteriormente. 

* Para verificar el estado de conexion con el dispositivo

```s
dmesg
```

* Copiamos el driver desde el repositorio oficial.

```s
sudo git clone https://github.com/aircrack-ng/rtl8812au.git
```

* Despues entramos al directorio y procedemos a la instalacion.

```s
cd rtl8812au/
sudo make dkms_install //si da error, primero intentar sudo make dkms_remove Para borrar el modulo instalado previamente
sudo make && make install
```

* Iniciamos el servicio y verificamos el funcionamiento.

```s
sudo modprobe 88XXau
iwconfig
```

### [](#header-3)Instalacion de Fluxion

Esta instalacion se ha vuelto mas compleja que la ultima vez que lo realice (2021), al dia de hoy (Julio 2022) pero me sirvio para agregarle seguridad a un repositorio de GIT La pagina oficial de done segui los pasos es <a href="https://fluxionnetwork.github.io/fluxion/"> aqui.</a> 

Una vez clonado el repositorio, podremos usar la herramienta, navegamos dentro de la carpeta de fluxion y usamos el comando:

```s
sudo ./fluxion.sh
#Si nos faltan herramientas por instalar podemos usar un
sudo ./fluxion.sh -i
```

### [](#header-3)Como usarlo

Una vez que el programa esta funcionando, tenemos opcion de continuar con algun ataque que hayamos intentado anteriormente, y seleccionando el handshake que anteriormente se tenia. En este caso empezaremos desde la captura del hanshake.

![Fluxion1 handshake](/assets/images/EvilTwin/fluxion1.png)

A continuacion seleccionamos la antena alpha, que se pondra en modo monitor automaticamente.

![Fluxion2 handshake](/assets/images/EvilTwin/fluxion2.png)

Ahora tenemos que escoger que tipo de senales queremos monitorear, si 2.4GHz o 5GHz, esta antena puede ver ambos asi que podemos escoger ambas opciones.

![Fluxion3 handshake](/assets/images/EvilTwin/fluxion3.png)

Podemos ahora esperar a que se vea la red que queremos interceptar, para ver mas informacion podemos hacer el recuadro mas grande, una vez que la visualicemos podemos parar la busqueda con CTRL+C.

![Fluxion3 handshake](/assets/images/EvilTwin/FluxionScan.png)

Ahora solo tendremos que seleccionar la red objetivo.

![Wifi List](/assets/images/EvilTwin/wifi_list.png)

Volvemos a escoger la interfaz donde esta la antena, esta vez para que deautentifique a los usuarios del otro AP y capture el handshake.

![Fluxion4 handshake](/assets/images/EvilTwin/fluxion4.png)

Lo siguiente sera escoger el tipo de ataque para obtener el handshake, a mi me gusta usar el 2

![Fluxion5 handshake](/assets/images/EvilTwin/fluxion5.png)
