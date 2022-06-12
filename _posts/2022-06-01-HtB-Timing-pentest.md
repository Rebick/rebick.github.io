---
layout: post
author: Sergio Salgado
published: false
---

## [](#header-2)Indice
Primero utilizaremos la herramienta que hace la identificación de conexión silenciosa y reconocimiento del sistema al que nos presentamos, su IP es `10.10.11.135` y veremos que se nos presenta una maquina Linux.

![Scan 1](/assets/images/Timing/scan1.png)

Ahora en el siguiente escaneo rapido, con nmap logramos ver que la maquina tiene el puerto 22 y 80 abiertos, por lo que debe existir una pagina web alojada por ahi.


![Nmap 1](/assets/images/Timing/nmap1.png)

En nuestro segundo escaneo ya vemos los nombres del servicio, que es el TCP y SSH, procederemos a enumerar las debilidades directamente a esos puertos con el tercer escaneo

![Nmap 2](/assets/images/Timing/nmap2.png)

Este escaneo, nos trae un login page asi que es un buen camino para empezar, al ingresar a el me recordo al login que se tenia en la maquina FingerPrint.

![Nmap 3](/assets/images/Timing/nmap3.png)

Proseguimos a enumerar las tecnologias usadas con whatweb.

![Whatweb](/assets/images/Timing/whatweb.png)

Ahora un poco de Fuzzing para enumerar dominios y subdominios con wfuzz. La busqueda no muestra nada interesante, asi que usare gobuster.

![gobuster](/assets/images/Timing/gobuster.png)

Ingresaremos en la unica pagina que no se redirige al loggin, que es /image.php. Aqui ingresaremos una imagen a travez del URL, de la manera: `http://10.10.11.135/image.php?img=php://filter/convert.base64-decoder/resource=/etc/passwd` 

![gobuster](/assets/images/Timing/url_php.png)

Hemos conseguido la informacion dentro de passwd, y vemos que el usuario al que nos dirigiremos ahora es aaron, pondremos su nombre como usuario y contrasena en el login page y resulta que esas son las credenciales.

![aaron](/assets/images/Timing/aaron.png)

Para analizar mejor lo que sucede cuando cargamos la imagen, podemos usar curl, de la siguiente manera:

```s
curl http://10.10.11.135/image.php?img=php://filter/convert.base64-encode/resource=profile.php | base64 -d
```