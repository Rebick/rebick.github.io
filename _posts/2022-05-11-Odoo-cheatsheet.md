---
title: Odoo Cheatsheet
published: True
---

# [](#header-1)Odoo cheatsheet

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#desarrollo">Desarrollo</a>

## [](#header-2)<a id="introduccion">Introduccion</a>
En este manual se detalla el proceso de desarrollo en Odoo, desde la instalacion, hasta la modificacion completa de este. 
Odoo es una plataforma de software libre que permite la gestión empresarial a través de sistemas ERP brindados por odoo con licenciamiento de sus módulos, también ofrece a través de su código abierto para desarrolladores o programadores la personalización y creación de módulos con Python.

## [](#header-2)<a id="desarrollo">Desarrollo</a>
### [](#header-3)<a id="proceso_instalacion">Proceso instalación</a>

VERSION 15

https://noviello.it/es/como-instalar-odoo-15-en-ubuntu-20-04/


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
