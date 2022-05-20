---
title: Odoo Cheatsheet
published: True
---

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#desarrollo">Desarrollo</a>

## [](#header-2)<a id="introduccion">Introduccion</a>
En este manual se detalla el proceso de desarrollo en Odoo, desde la instalacion, hasta la modificacion completa de este. 
Odoo es una plataforma de software libre que permite la gestión empresarial a través de sistemas ERP brindados por odoo con licenciamiento de sus módulos, también ofrece a través de su código abierto para desarrolladores o programadores la personalización y creación de módulos con Python.

## [](#header-2)<a id="desarrollo">Desarrollo</a>
### [](#header-3)<a id="proceso_instalacion">Proceso instalación</a>
Script de instalación de Odoo en Ubuntu
- Se muestra paso a paso la instalación y se recomienda seguirla e ir entendiendo el proceso seguido.
- Se predispone al usuario con conocimientos básicos de Linux/Ubuntu
- Se solucionan posibles errores que han surgido durante la instalación.
- Mas informacion en: 
    - <a href="https://www.odoo.com/documentation/13.0/administration/install/deploy.html">https://www.odoo.com/documentation/13.0/administration/install/deploy.html</a>
    
    - <a href="https://noviello.it/es/como-instalar-odoo-15-en-ubuntu-20-04/">https://noviello.it/es/como-instalar-odoo-15-en-ubuntu-20-04/</a>


- <a href="">Instalacion de dependencias</a>

```sc
#actualizacion de paquetes
sudo apt update

sudo apt install git python3-pip build-essential wget python3-dev python3-venv \
    python3-wheel libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev \
    python3-setuptools node-less libjpeg-dev zlib1g-dev libpq-dev \
    libxslt1-dev libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev \
    liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev
```

### [](#header-3)<a id="creacion de usuario">Creacion de usuario</a>
Ejecutar Odoo como super usuario, representa un riesgo de seguridad, por lo que crearemos un usuario especifico para su ejecusion. grupo del sistema con el directorio de inicio /opt/odoo15que ejecutará el servicio Odoo. Para hacer esto, ejecute el siguiente comando:

```sc
sudo useradd -m -d /opt/odoo15 -U -r -s /bin/bash odoo15
```

Se puede nombrar al usuario como desee, siempre que cree un usuario de PostgreSQL con el mismo nombre

### [](#header-3)<a id="intalacion_configuracion_PSQL">Instalar y configurar PostgreSQL</a>

PostgreSQL se encuentra en los repositorios oficiales de ubuntu, asi que su instalacion sera sencilla, solo utilizaremos el comando:

```sc
sudo apt install postgresql
```
Una vez que el servicio esté instalado, cree un usuario de PostgreSQL con el mismo nombre que el usuario del sistema creado anteriormente. En este ejemplo, eso es odoo15:

```sc
sudo su - postgres -c "createuser -s odoo15; psql template1; alter odoo15 with password '@odoo'"
```

## [](#header-2)<a id="configurar_postgres">Configuracion PostgreSQL</a>

### [](#header-3)<a id="espacios_tablas">Los espacios de tablas</a>

Informacion obtenida de: https://programmerclick.com/article/6898460613/

Un espacio de tablas es un directorio de un sistema de archivos, en el que PostgreSQL escribe los archivos de las tablas y de los índices. Por defecto, PostgreSQL dispone de un espacio de tablas ubicado en el directorio del grupo de bases de datos. Es posible crear otros espacios de tablas, que permiten al administrador seleccionar de esta manera la ubicación del almacenamiento de una tabla o de un índice.

Hay varios motivos que pueden hacer que un administrador cree un espacio de tablas:

- La partición ya no dispone de suficiente espacio libre. En este caso, los espacios de tablas permiten utilizar varios discos duros diferentes para un mismo grupo de base de datos, sin utilizar sistemas de volúmenes lógicos, como LVM en los sistemas GNU/Linux.

- La utilización de las tablas y de los índices provoca una saturación de las escrituras y lecturas del subsistema de disco en el que se ubica el espacio de tablas por defecto. Incluso en los sistemas de alto rendimiento, el escalado de una aplicación puede hacer que el administrador cree otros espacios de tablas en los subsistemas de discos diferentes. De esta manera, las escrituras y lecturas de archivos de tablas e índices se reparten en varios soportes físicos, mejorando el rendimiento.


Por lo tanto, un espacio de tablas es una herramienta que se puede utilizar por el administrador del servidor de bases de datos, que permite intervenir sobre la ubicación física del almacenamiento.


Crear espacio de tabla
Syntax:

```sc
CREATE TABLESPACE tablespace_name [ OWNER { new_owner | CURRENT_USER | SESSION_USER } ] LOCATION ‘directory’
```

Ejemplos son:
```sc
postgres=# c lottu postgres
You are now connected to database “lottu” as user “postgres”.
lottu=# CREATE TABLESPACE tsp01 OWNER lottu LOCATION ‘/data/pg_data/tsp’;
CREATE TABLESPACE
```

El directorio "/data/pg_data/tsp" debe ser un directorio vacío existente y pertenecer al usuario del sistema operativo PostgreSQL
mkdir −p /data/pg_data/tsp chown -R postgres:postgres /data/pg_data/tsp

### [](#header-3)<a id="asignacion_permisos">Asignación de permisos</a>

La creación del espacio de tabla en sí debe realizarse como un superusuario de la base de datos, pero después de la creación, puede permitir que los usuarios comunes de la base de datos lo usen. CREAR permiso en. Las tablas, los índices y toda la base de datos se pueden asignar a espacios de tabla específicos.
Usuario de muestra "rax": usuario normal.
```sc
lottu=# c lottu01 rax
You are now connected to database “lottu01” as user “rax”.
lottu01=> create table test_tsp(id int) tablespace tsp01;
ERROR: permission denied for tablespace tsp01
lottu01=> c lottu01 postgres
You are now connected to database “lottu01” as user “postgres”.
lottu01=# GRANT CREATE ON TABLESPACE tsp01 TO rax;
GRANT
lottu01=# c lottu01 rax
You are now connected to database “lottu01” as user “rax”.
lottu01=> create table test_tsp(id int) tablespace tsp01;
CREATE TABLE
```

Especificar un espacio de tabla predeterminado para la base de datos
```
ALTER DATABASE name SET TABLESPACE new_tablespace
```

Tome la base de datos lottu01 como ejemplo:
```
ALTER DATABASE lottu01 SET TABLESPACE tsp01;
lottu01=> c lottu01 lottu
You are now connected to database “lottu01” as user “lottu”.
```

*---*
### [](#header-3)<a id="instalar_wkhtmltopdf">Instalar wkhtmltopdf</a>
wkhtmltopdf es un conjunto de herramientas de línea de comandos de código abierto para renderizar páginas HTML en PDF y varios formatos de imagen. Para imprimir informes PDF en Odoo, deberá instalar el paquete wkhtmltox.

La versión de wkhtmltopdf incluida en los repositorios de Ubuntu no admite encabezados ni pies de página. La versión recomendada para Odoo es 0.12.5. Descargaremos e instalaremos el paquete desde Github:

```sc
sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
```

Una vez descargado el archivo, instálelo escribiendo:

```sc
sudo apt install ./wkhtmltox_0.12.5-1.bionic_amd64.deb
```

### [](#header-3)<a id="instalar_configurar_odoo">Instalar y configurar Odoo 15</a>
Instalaremos Odoo desde la fuente dentro de un entorno virtual de Python aislado.

Primero, cambie al usuario "odoo15":

```sc
sudo su - odoo15
```

Clona el código fuente de Odoo 15 desde GitHub:

```sc
git clone https://www.github.com/odoo/odoo --depth 1 --branch 15.0 /opt/odoo15/odoo
```

Cree un nuevo entorno virtual de Python para Odoo:

```sc
cd /opt/odoo15
```


```sc
python3 -m venv odoo-venv
```

Activar el entorno virtual:

```sc
source odoo-venv/bin/activate
```

Las dependencias de Odoo se especifican en el archivo require.txt. Instale todos los módulos de Python necesarios con pip3:

```sc
pip3 install wheel
```
```sc
pip3 install -r odoo/requirements.txt
```
Una vez hecho esto, desactive el entorno escribiendo:
```sc
deactivate
```
Cree un nuevo directorio, un directorio separado para los complementos de terceros:
```sc
mkdir /opt/odoo15/odoo-custom-addons
```
En los siguientes pasos agregaremos este directorio al parámetro addons_path. Este parámetro define una lista de directorios en la que Odoo busca módulos.
```sc
# /opt/odoo15/odoo-custom-addons
```

Regrese a su usuario de sudo:
```sc
exit
```
Cree un archivo de configuración con el siguiente contenido:
```sc
sudo nano /etc/odoo15.conf
```

```sc
[options]
; This is the password that allows database operations:
admin_passwd = my_admin_passwd
db_host = localhost
db_name = test
db_port = 5432
db_user = odoo15
db_password = @odoo
addons_path = /opt/odoo15/odoo/addons,/opt/odoo15/odoo-custom-addons
xmlrpc_port = 8069 
```

No olvide cambiarse my_admin_passwd a algo más seguro.
Si se desea cambiar el puerto del servicio, solo hay que cambiarlo en la opcion de xmlrpc_port.


Cree el archivo de la unidad Systemd

Un archivo de unidad es un archivo de configuración de estilo ini que contiene información sobre un servicio.

Abra su editor de texto y cree un archivo odoo15.servicecon nombre con el siguiente contenido:

```sc
sudo nano /etc/systemd/system/odoo15.service
```

```sc
[Unit]
Description=Odoo15
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo15
PermissionsStartOnly=true
User=odoo15
Group=odoo15
ExecStart=/opt/odoo15/odoo-venv/bin/python3 /opt/odoo15/odoo/odoo-bin -c /etc/odoo15.conf -d [DatabaseName]
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
```
Notifica a systemd que existe un nuevo archivo de unidad:

```sc
sudo systemctl daemon-reload
```

Inicie el servicio Odoo y habilítelo para que se inicie en el inicio ejecutando:

```sc
sudo systemctl enable --now odoo15
```

Verifique que el servicio esté en funcionamiento:
```sc
sudo systemctl status odoo15
```

La salida debería verse así, mostrando que el servicio Odoo está en funcionamiento:
```sc
● odoo15.service - Odoo15
     Loaded: loaded (/etc/systemd/system/odoo15.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2021-10-26 04:56:28 UTC; 18s ago
...

```

Puede verificar los mensajes grabados por el servicio Odoo usando el siguiente comando:
```sc
sudo journalctl -u odoo15
```

### [](#header-3)<a id="Prueba_instalación">Prueba la instalación</a>

Abra su navegador y escriba: http://<your_domain_or_IP_address>:8069

Suponiendo que la instalación se haya realizado correctamente, aparecerá una pantalla similar a la siguiente:


### [](#header-3)<a id="entorno_programacion">CONFIGURACION DEL ENTORNO DE PROGRMACION</a>
Agregar a la ruta de ejecución de comandos en odoo-bin, agregar el script de inicio de programa -c odoo.conf -d datatest --dev=all



Insertar en el link esta especificacion para activar las herramientas de desarrollador
?debug=1
### [](#header-3)<a id="estructura_odoo">Estructura de Odoo</a>

#### [](#header-4)<a id="tipos_modelos">Tipos de modelos</a>
**Model:** Son los modelos estandar, almacenados en una base de datos que nos permiten las operaciones la lectura, escritura, modificado y borrado. Se suele usar en el 90% de los casos 
**Transient Model:** Datos temporales que pueden ser almacenados en la base de datos y borrados de manera no determinista, esto quiere decir que nosotros no controlamos cuando se almacenan o se borran, esto lo determina el mismo ORM.
**Abstract Model:**Son los modelos utilizados para definir las clases abstractas que sean redadas por multiples modelos.

#### [](#header-4)<a id="creacion_modulos">Creacion de Modulos</a>

```sc
sudo ./odoo-bin scaffold -h
#parametro name Nombre del modulo
#parametro dest, destino de directorio para crear el modulo
```
#### [](#header-4)<a id="tipos_campos">Campos</a>

odoo.fields.Boolean
odoo.fields.Char
odoo.fields.Float
odoo.fields.Integer
odoo.fields.Binary
odoo.fields.Html
odoo.fields.Image
odoo.fields.Monetary
odoo.fields.Selection
odoo.fields.Text    Cadenas de texto largas
odoo.fields.Date    Solo la fecha
odoo.fields.DateTime    Fecha y hora

**Relaciones**
Many2one
One2Many
Many2many

**Atributos de Campos**
string: Etiqueta que se muestra
help:Tooltip de Ayuda 
readonly: Atributo de solo lectura
required:Campo obligatorio
index: Si el campo indexa en Base de datos
default:Valor por defecto (Estatico o funcion)
