---
layout: post
author: Sergio Salgado
---

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#descargas_config">Descargas y configuraciones</a>
- <a href="#internal_network">Redes internas de docker</a>

## [](#header-2)<a id="introduccion">Introduccion</a>
Docker es una alternativa a la gestion de contenedores como Parallels que en su momento tambien lo mencionaron en mi maestria. Para gestionar servicios de seguridad como navegadores seguros o verificacion de archivos tambien existe otro SO que se llama QUBES, de linux y contiene las aplicaciones fuera del sistema operativo host, pero te facilita tambien el intercambio de archivos entre estos contenedores.

## [](#header-2)<a id="descargas_config">Descargas y configuraciones</a>
Empezaremos este breve manual descargando una imagen de docker hub con el comando

*Todos los comandos se deben ejecutar con sudo para que el daemon de docker reaccione*

```s
#Imagen de Webgoat de OWASP, este sera nuestro servidor inseguro
sudo docker pull webgoat/webgoat-8.0
sudo docker pull scollazo/naxsi-waf-with-ui
```
Para verificar las imagenes que tenemos descargadas podemos hacer un:

```s
sudo docker image ls
```

Para borrar los contenedores podemos hacer un

```s
#Borra en general
docker container prune

#Borrar individualmente 
docker rm -f [Container]
```

Para iniciar el WAF y proteger nuestro servidor inseguro, usaremos NAXSI

Para iniciar con una shell iteractiva podemos agregar un 

```s
sudo docker run -it ubuntu:waf_test
```

Para iniciar con un nombre especifico, haremos un

```s
docker run -d --name webGoat webgoat/webgoat-8.0
```

Para iniciar un contenedor con una variable de entorno

```s
docker run -d --name WAF -p [MAquina]:[contenedor] --env WEBSERVER=[nombre contenedro]:[PORT] scollazo/naxsi-waf-with-ui
```

Para publicar una imagen haremos un

```s
sudo docker login
#Para crear nuestra propia version de la imagen primero haremos un
socker tag ubuntu:waf_test rebick/ubuntu:waf_test
sudo docker push rebick/ubuntu:waf_test
```

![Comandos](/assets/images/docker_platzi/carbon%20(3)-975f4d64-9144-4a75-a8ba-0eceba66db50.webp)

Otro asunto importante es que a veces no podemos ver como se configuro una imagen, y para ver como se configuro existen unos tags, para entrar en ellos podemos usar una herramienta llamada <a href="https://github.com/wagoodman/dive.git">dive</a>

## [](#header-2)<a id="internal_network">Redes internas de docker</a>
Docker dispone de interfaces de redes para comunicacion entre los contenedores, para listarlos usaremos el comando

```s
docker network ls
```
Bridge que es el default de docker.

Host es una representacion en docker de la red real de la maquina, si quisiera que un contenedor tuviera acceso a todas las maquinas tendria que permitirle usar esta red.

none, seria para que el contenedor no pudiera tener acceso a la red.

![Network list](/assets/images/docker_platzi/network_ls.png)

Tambien podemos crear nuestra propia red con:

```s
docker network create wafnet
#Para que los contenedores se puedan conectar a esta red solo agregariamos el parametro attachable
docker network create --atachable wafnet
#Para ver las opciones de la red
docker network inspect wafnet
#Para conectar un contenedor a una red
docker network connect wafnet [nombre del contenedor]
```

## [](#header-2)<a id="practica">Practica</a>

Corremos el contenedor del servicio vulnerable, exponemos el puerto 8081 de nuestra maquina y lo visualizamos como el puerto 8080 del contenedor.

```s
sudo docker run -it -p 8081:8080 --name webGOAT webgoat/webgoat-8.0
```

Corremos el contenedor de naxsi y lo configuramos para exponer el puerto 8080 de nuestra maquina y visualizarlo como el 8080 de naxsi.

```s
sudo docker run -e BACKEND_IP=webGOAT -it -p 8080:80 --name naxsi scollazo/naxsi-waf-with-ui
```
