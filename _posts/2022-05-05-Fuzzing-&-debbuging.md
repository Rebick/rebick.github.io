---
title: Fuzzing & Debbuging
published: false
layout: post
author: Sergio Salgado
---
# [](#header-1)Maquina Timelapse

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#desarrollo">Desarrollo</a>
  - <a href="#Especificaciones_del_laboratorio">Especificaciones del laboratorio</a>
  - <a href="#fuzzing">Fuzzing</a>
  - <a href="#payload_creation">Gain Access</a>
  - <a href="#privilege_scalation">Escalamiento de privilegios</a>

## [](#header-2)<a id="introduccion">Introduccion</a>
Las aplicaciones sin pruebas de seguridad tienden a tener vulnerabilidades en su código, podría
estar haciendo llamadas a módulos o librerías inseguras. En este entregable se pondrá en práctica lo
aprendido en el curso de Seguridad para aplicaciones móviles, y se utilizara una aplicación desde la
página exploit-db con vulnerabilidad para fuzzing y buffer-overflow.
Cuando existen estas vulnerabilidades prácticamente uno puede tomar control total del dispositivo
que está ejecutando el programa.
El entorno donde trabajaremos es virtual, el dispositivo tiene una arquitectura x86 y un sistema
operativo Windows XP.

## [](#header-2)<a id="desarrollo">Desarrollo</a>
### [](#header-3)<a id="Especificaciones_del_laboratorio">Especificaciones del laboratorio</a>
Se utilizará una máquina virtual con sistema operativo Windows XP de 32 bits y una maquina Kali Linux enlazadas por red y permitiendo el tráfico de datos entre estas.

Para el análisis del software utilizado en la maquina Windows xp, se utilizará la aplicación immunity debbuger, que es un desensamblador de programas y con esto podemos estar monitoreando la ejecución del sistema

-Immunity debugger

![Debbuging Tools](/assets/images/fuzzing&debbuging/debbug_tools.png)

-Programa a utilizar FTPserver, obtenida del link https://www.exploit-db.com/exploits/46763

### [](#header-3)<a id="fuzzing">Fuzzing</a>
El siguiente programa escrito en python, tiene bloques importantes, el que define los caracteres o cadena con la que se hará el testing, el que realiza el envió de la información.

La cadena en este caso será una A multiplicada por 10mil, al ser ejecutado mandará al servidor FTP una cadena de 10mil bytes despues de pasar el usuario y contraseña.

```py
#!/usr/bin/python2

import socket

cadena = 'A' * 10000

s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
conexion = s.connect(('192.168.100.252',21))
s.recv(1024)
s.send('USER ftp\r\n') #USUARIO
s.recv(1024)
s.send('PASS ftp\r\n') #PASS
s.recv(1024)
s.send('STOR' + cadena + '\r\n')
s.recv(1024)
s.send ('QUIT\r\n')
s.close()
```

Al ejecutar este programa, podemos verificar que se están almacenando As en la memoria de la máquina, cuando son demasiadas podremos interrumpir el programa y prácticamente hacer un ataque de denegación del servicio, pero aquí no queda todo, se puede seguir estudiando el programa para seguir ahora con un ataque de buffer overflow. 

![Fuzzing Test 1](/assets/images/fuzzing&debbuging/fuzzing_1.png)

En la imagen se aprecia que estamos escribiendo en la memoria de propósito general ESP, utilizando solamente mil bytes para la prueba y con esto podemos proceder al buffer overflow.

### [](#header-3)<a id="fuzzing">Buffer overflow</a>
¿Como funciona un buffer overflow? En este articulo se menciona algo importante que es la arquitectura de las computadoras o el tipo de procesador que tienen estas, al ser diferentes las computadoras, la ejecución de un programa tiene llamadas diferentes a las librerías del mismo procesador, entonces para ejecutar un programa con éxito se deberá conocer a detalle la arquitectura especifica de esta. Recientemente apple saco su computadora que contiene un procesador que esta desarrollado por ellos y es mas complicado el explotar sus vulnerabilidades, al ser un dispositivo que no esta al alcance de muchas personas pues no existen personas dedicadas o enfocadas a beneficiarse por este medio.

![Apuntadores de proposito general](../_posts/images/fuzzing&debbuging/apuntadores.png)

Una vez conociendo el punto aproximado del desbordamiento, empezaremos a tener el control del programa, mandando la cadena del con el siguiente patrón, podremos determinar en qué punto o con que cantidad exacta de bytes deja de funcionar el programa.

```S
msf-pattern_create --l 3500         #para crear el patrón

msf-pattern_offset -q 0012FED0        #para hacer la consulta del patrón
```

Teniendo en cuenta los apuntadores principales, con el código anterior determinaremos la cantidad exacta en la que el programa es interrumpido y empezar a notar en que segmentos del programa escribe en los apuntadores de propósito general.

Para despues hacer un llamado a funciones del sistema que nos permitan establecer una conexión remota con otra computadora.

Para el siguiente análisis, utilizaremos una cadena de mil bytes, para que el programa nos indique en que lugar de memoria empezamos a escribir.

![Desbordamiento de buffer](/assets/images/fuzzing&debbuging/debug1.png)

Obtenemos los caracteres i6Ai para el ESP, y con estos podemos empezar la consulta, también tenemos los yZAy para el EDI

![Consulta Offset](/assets/images/fuzzing&debbuging/debug1.png)

A continuación, con el programa en pausa, buscamos las librerías o dll de interés, dando click en la e minúscula de la barra superior, pondremos atención en el modulo ejecutable que se llama USER32, este modulo tiene muchas funciones, entre ellos para hacer pruebas podemos abrir un messagebox, para notificarnos que tenemos acceso o simplemente la ejecución de algún programa que desarrollemos.

![dll usadas](/assets/images/fuzzing&debbuging/dll_used.png)

Ahora que dimos doble click en el modulo ejecutable de USER32, podemos buscar la dirección de memoria en donde se ejecuta el jmp_esp, ya que cada computadora lo puede ejecutar en diferente dirección dependiendo su arquitectura y por eso es necesario especificar esto para fines generales. En este caso lo tendremos en la dirección 7E429353, este dato es importante para hacer la llamada de esta función en la interrupción del programa. En el siguiente paso se describirá en que parte es necesario y como deberá ser su implementación.

![Uso de ESP](/assets/images/fuzzing&debbuging/esp_usage.png)

### [](#header-3)<a id="payload_creation">Creación de payload y programa de inserción </a>
