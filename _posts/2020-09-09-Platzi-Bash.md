---
layout: post
author: Sergio Salgado
---
## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#descripciones">Descripciones</a>
- <a href="#acciones_rapidas">Instalacion</a>
- <a href="#configuracion">Configuracion</a>
- <a href="#conexion">Establecer conexion</a>
- <a href="#conclusiones">Conclusiones</a>

## [](#header-2)<a id="introduccion">Introduccion</a>


## [](#header-2)<a id="descripciones">Descripciones</a>
Cabecera
```s
#!/bin/bash
```

Variable
```s
WELCOME="Hola Rebick"
```

Print
```s
echo $WELCOME
```

## [](#header-2)<a id="acciones_rapidas">Acciones rapidas</a>

En ocaciones es util tener salidas de diferentes colores, para ello tenemos este atajo.

```s
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

```

## [](#header-2)<a id="acciones_rapidas">Detector de Sistemas Operativos</a>