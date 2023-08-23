---
layout: post
author: Sergio Salgado
---

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#Search_Engine">Descargas y configuraciones</a>

## [](#header-2)<a id="introduccion">Introduccion</a>

Para esta tecnica, la palabra clave es el crawling; que como un gusano programado, se encarga de navegar un sitio y extenderse a traves de el en busca de keywords (mas sencillo que elaborar una wordlist). En esta ocacion, para mejorar sus resultados de busqueda, google conoce las palabras clave de las paginas publicas, tambien sabe los documentos que conforman la pagina; entonces nosotros podremos hacerle consultas mas especificas sobre el material con el que queremos trabajar.
En este post, mostrare ejemplos de la academia de tryhackme.com

## [](#header-2)<a id="Search_Engine">Introduccion</a>
Como ver la calificacion de el motor de busqueda que asigna google? 
Para esto podemos usar: <a href="https://pagespeed.web.dev">Google Site's Analyzer</a>

Que archivos son importantes en un sitio?
En la ruta raiz normalmente se encuentra el archivo site.xml que es el mapa del sitio, y el otro archivo importante que podemos encontrar es el robots.txt que es el archivo que permitira a los navegadores indexar el sitio con sus crawlers.

Los comandos son:

|:---|:-----------------------|:-----------------|
| #  |      **Termino**       |     **Accion**   |
|:---|:-----------------------|:-----------------|
| 1  | filetype:              | Busca el archivo por su extension |
|:---|:-----------------------|:-----------------|
| 2  | cache:                 | Ver la version en cache de Google de una URL especifica |
|:---|:-----------------------|:-----------------|
| 3  | intitle:               | La frase especifica debera estar en el titulo de la pagina |
|:---|:-----------------------|:-----------------|
| 4  | inurl:               | La frase especifica debera estar en la URL |
|:---|:-----------------------|:-----------------|
| 5  | :ftp              | Se puede usar para encontrar hasta servidores ftp ejemplo: shakespeare:ftp |
|:---|:-----------------------|:-----------------|
| 6  | :link              | Lista las paginas que tienen el link del sitio presente |
|:---|:-----------------------|:-----------------|
| 7  | :related              | Lista las paginas que son similares al sitio |
|:---|:-----------------------|:-----------------|
| 8  | :info              | Presenta informacion que tenga google sobre el sitio |
|:---|:-----------------------|:-----------------|
| 9  | :allintitle              | Restringe el resultado a sitios que contengan el keyword en el titulo |
|:---|:-----------------------|:-----------------|
| 10 | :allinurl              | Restringe el resultado a sitios que contengan el keyword en la URL |
|:---|:-----------------------|:-----------------|
| 11 | :location              | Encuentra informacion en una ubicacion en especifico |
|:---|:-----------------------|:-----------------|