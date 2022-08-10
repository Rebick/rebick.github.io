---
layout: post
author: Sergio Salgado
---

## [](#header-2)Introduccion

Lo que dice el comentario de esta app, es que esta app ha almacenado sus credenciales y ahora solo puede conectarse automaticamente. Ha intentado interceptar el request y restablecer su contrasena, pero parece que estan viajando por una conexion segura, podremos ayudar a bypassear esta restriccion de seguridad e interceptar la contrasena en texto plano?

## [](#header-2)Desarrollo
Android tiene almacenados 3 tipos de certificados de TLS/SSL para comunicacion al servidor
- adb connect [IP] 
Esta almacenada en la ruta /system/etc/security/cacerts, en la ruta /data/misc/user/0/cacerts-added/ estan los certificados de confianza del usuario 1 y pueden ser instalados manuelmente por el usuario del dispositivo, estos certificados son de confianza por default por versiones < a Android 7 pero en la actualidad cada aplicacion tiene que actualizar la confianza para ellos

El primer comando, para desensamblar la aplicacion sera:

```s
apktool d pinned.apk
```

![APKTOOL](/assets/images/CHALLENGES/MOBILE/Pinned/apktool.png)

Con el siguiente comando veremos que no hay ninguna indicacion en el archivo de manifiesto para version de API minima para su uso.

```s
cat pinned/AndroidManifest.xml
```

![API version](/assets/images/CHALLENGES/MOBILE/Pinned/APIv.png)

Ahora con Gennymotion crearemos un dispositivo con las siguientes caracteristicas

Para agregar un dispositivo nuevo le damos al boton con el +

![Gennytool ](/assets/images/CHALLENGES/MOBILE/Pinned/gennymotion.png)

El dispositivo que eligiremos tendra Android 6.0API

![Google nexus 5](/assets/images/CHALLENGES/MOBILE/Pinned/g1.png)

Ahora para compartirnos informacion podemos solamente arrastrar el archivo y dejarlo en el celular.  
- Necesitaremos primero pasar el .apk al dispositivo.
- Despues habra que exportar el certificado de CA de burpsuite, este esta en formato DER, habra que pasarlo a .pem con openssl con los comandos:

```s
openssl x509 -in cert.der -out cert.pem
```

Pasamos el certificado al telefono y este estara en la memoria sd guardado. Para que en configuraciones busquemos cert, carguemos el archivo.

-Despues habra que configurar avanzadamente el wifi para que pase por un proxy a traves de nuestra ip de la kali y su respectivo puerto del burpsuite.


Ahora podemos hacer una prueba interceptando la peticion de logeo en la aplicacion del celular.
Con esto aun no podremos, ya que revisando el codigo desensamblado, podremos notar que hay una funcion w, que carga y almacena un certificado en una funcion llamada keyStore que es la que recomienda owasp revisar para este tipo de certificados con TLS.

Para encontrar el folder de donde esta cargando el certificado la aplicacion podemos hacer un 

```s
printf "%x\n" 2131623936
```

Podemos ver que en el archivo com/example/MainActivity que es donde se esta presionando el boton de login se llama a la funcion del certificado, y hace la peticion por POST, esto dificulta la conexion por que esta siendo comparada la conexion en otra funcion y si falla esta parte la conexion podria declararse insegura.

Para pasar este problema que nos encontramos, usaremos FRIDA, 
- Nos conectamos al dispositivo con un:

```s
adb connect {IP}
adb shell
#Los certificados ca se encuentran en /system/etc/security/cacerts/, del usuario en /data/misc/user/0/cacerts-added y de la aplicacion en /res/raw
#subimos frida-server al dispositivo con un
adb push frida-server /data/local/tmp/
#nos desplazamos a /data/local/tmp/
# le cambiamos los permisos a 755 
#ejecutamos con un ./frida-server
#Para probar frida podemos hacer un
frida-ps -Ua
```
 Ahora podemos capturar la funcion w que pasa por el certificado TLS.

 Lo siguiente sera hacernos una copia del codigo que viene en el siguiente  <a href="https://codeshare.frida.re/@pcipolloni/universal-android-ssl-pinning-bypass-with-frida/">link</a> .

Ahora podemos pasar nuestro archivo de burp-cert a:

```s
adb push ~/Documents/burp-cert /data/local/tmp/burp-cert.crt
#Ahora cargamos el archivo que se llevara el script del certificado.

frida -U -f com.example.pinned -l hook.js --no-pause
```

Y ahora ya podremos usar nuestro propio certificado. Mandamos la peticion de login y listo.

![Google nexus 5](/assets/images/CHALLENGES/MOBILE/Pinned/frida1.png)

![Google nexus 5](/assets/images/CHALLENGES/MOBILE/Pinned/powned.png)