---
layout: post
author: Sergio Salgado
---
# [](#header-1)Pasos
>Introduccion
>Identificar los caracteres que necesitamos
>Filtrado de caracteres utilizando regex

Muchas veces al comunicarnos directamente con otro dispusitivo, su respuesta es en lenguaje maquina, este
es representado en codigo binario, hexadecimal u octal. En este articulo se explicara como se resuelve esta practica sencilla.

La cadena que utilizaremos es del siguiente formato

```py
// Python code with syntax highlighting.
#Estructura de la cadena en hexadecimal
hexa_result = b'\xd0\x00\x00\xff\xff\x03\x00\x04\x00\x00\x00\x01\x00'
```

## [](#header-2)Identificar los caracteres que necesitamos
Para este ejercicio los caracteres que necesitamos los manejaremos con las siguientes variables al final, para establecer nuestro objetivo, dejo el ejemplo de como las necesitaremos.
```py
// Python code with syntax highlighting.
#Numeros necesarios de la cadena(Ultimos 2 caracteres de la cadena)
second_result = x01
third_result = x00
```
## [](#header-2)Filtrado de caracteres utilizando regex
Viene la parte mas interesante, el filtrado con regex, utilizaremos 3 filtrados, en el primero obtendremos los dos ultimos caracteres que corresponden a los numeros que necesitamos, para mi regla de regex me apoye de la comilla simple *'* para tomar los dos ultimos numeros, y el bloque de codigo quedo como la siguiente:
```py
// Python code with syntax highlighting.
#Obtenemos los 2 ultimos caracteres a utilizar
def get_hexa_number(hexa_result):
    hexa_result_search_filter = re.search(r"\\\w*\\\w*'", str(hexa_result))
    if hexa_result_search_filter:
        return hexa_result_search_filter
        print("La cadena filtrada es", hexa_result_search_filter)
    else:
        #Si la cadena no esta presente, manejamos el error de esta manera
        print("No se han encontrado caracteres de respuesta en el filtro 1")
```
## [](#header-2)