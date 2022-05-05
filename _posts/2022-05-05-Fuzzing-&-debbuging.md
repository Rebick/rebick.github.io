---
title: Fuzzing & Debbuging
published: false
layout: post
author: Sergio Salgado
---
# [](#header-1)Maquina Timelapse

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#reconocimiento">Reconocimiento</a>
- <a href="#escaneo">Escaneo</a>
  - <a href="#gain_access">Gain Access</a>
  - <a href="#privilege_scalation">Escalamiento de privilegios</a>

## [](#header-2)<a id="introduccion">Introduccion</a>
Las aplicaciones sin pruebas de seguridad tienden a tener vulnerabilidades en su código, podría
estar haciendo llamadas a módulos o librerías inseguras. En este entregable se pondrá en práctica lo
aprendido en el curso de Seguridad para aplicaciones móviles, y se utilizara una aplicación desde la
página exploit-db con vulnerabilidad para fuzzing y buffer-overflow.
Cuando existen estas vulnerabilidades prácticamente uno puede tomar control total del dispositivo
que está ejecutando el programa.
El entorno donde trabajaremos es virtual, el dispositivo tiene una arquitectura x86 y un sistema
operativo Windows XP.