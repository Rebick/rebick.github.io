---
layout: post
author: Sergio Salgado
---
# [](#header-1)Pasos
- <a href=#Introduccion>Introduccion</a>
- Identificar los caracteres que necesitamos
- Conversiones
  - De binario a decimal
  - De octal a decimal
  - De hexadecimal a decimal
  - De ascii a decimal
- Filtrado de caracteres utilizando regex
    -Filtro para ultimos 2 registros
    -Filtro para caracter despues de la 'x'
    -Filtro para tomar letra ascci
- Conclusiones

## [](#header-2)<a id=Introduccion>Introduccion</a>
Muchas veces al comunicarnos directamente con otro dispositivo, su respuesta es en lenguaje maquina, este
es representado en codigo binario, octal, hexadecimal o ascii. En este articulo se explicara como se resuelve esta practica sencilla.

La cadena que utilizaremos es del siguiente formato

```py
// Python code with syntax highlighting.
#Estructura de la cadena en hexadecimal
hexa_result = b'\xd0\x00\x00\xff\xff\x03\x00\x04\x00\x00\x00\x01\x00'
```

## [](#header-2)Identificar los caracteres que necesitamos
Para este ejercicio los caracteres que necesitamos los manejaremos con las siguientes variables al final, para establecer nuestro objetivo, dejo el ejemplo de como las necesitaremos en el siguiente
```py
# 9 = \t\x00 # 10 = \n\x00 # 13 = \r\x00
# 33 = \x00!\x00 # 34 = \x00"\x00 # 35 = \x00#\x00
# 36 = \x00$\x00 # 37 = \x00%\x00 # 38 = \x00&\x00
# 39 = \x00'\x00 # 40 = \x00(\x00 # 41 = \x00)\x00
# 42 = \x00*\x00 # 43 = \x00+\x00 # 44 = \x00,\x00
# 45 = \x00-\x00 # 46 = \x00.\x00 # 47 = x00/\x00
# 48 = \x000\x00 # 49 = \x001\x00 # 50 = \x002\x00
# 51 = \x003\x00 # 52 = \x004\x00 # 53 = \x005\x00
# 54 = \x006\x00 # 55 = \x007\x00 # 56 = \x008\x00
# 57 = \x009\x00 # 58 = \x00:\x00 # 59 = \x00;\x00
# 60 = \x00<\x00 # 61 = \x00=\x00 # 62 = \x00>\x00
# 63 = \x00?\x00 # 64 = \x00@\x00 # 65 = \x00A\x00 = 10
# 66 = \x00B\x00 = 11 # 67 = \x00C\x00 = 12 # 68 = \x00D\x00 = 13
# 69 = \x00E\x00 = 14 # 70 = \x00F\x00 = 15 # 71 = \x00G\x00 = 16
# 72 = \x00H\x00 = 17 # 73 = \x00I\x00 # 74 = \x00J\x00
# 75 = \x00K\x00 # 76 = \x00L\x00 # 77 = \x00M\x00
# 78 = \x00N\x00 # 79 = \x00O\x00 # 80 = \x00P\x00
# 81 = \x00Q\x00 # 82 = \x00R\x00 # 83 = \x00S\x00
# 84 = \x00T\x00 # 85 = \x00U\x00 # 86 = \x00V\x00
# 87 = \x00W\x00 # 88 = \x00X\x00 # 89 = \x00Y\x00
# 90 = \x00Z\x00 # 91 = \x00[\x00 # 92 = \x00\\x00
# 93 = \x00]\x00 # 94 = \x00^\x00 # 95 = \x00_\x00
# 96 = \x00`\x00 # 97 = \x00a\x00 = 10 # 98 = \x00b\x00 = 11
# 99 = \x00c\x00 = 12 # 100 = \x00d\x00 = 13 # 101 = \x00e\x00 = 14
# 102 = \x00f\x00 # 103 = \x00g\x00 # 104 = \x00h\x00
# 105 = \x00i\x00 # 106 = \x00j\x00 # 107 = \x00k\x00
# 108 = \x00l\x00 # 109 = \x00m\x00 # 110 = \x00n\x00
# 111 = \x00o\x00 # 112 = \x00p\x00 # 113 = \x00q\x00
# 114 = \x00r\x00 # 115 = \x00s\x00 # 116 = \x00t\x00
# 117 = \x00u\x00 # 118 = \x00v\x00 # 119 = \x00w\x00
# 120 = \x00x\x00 # 121 = \x00y\x00 # 122 = \x00z\x00
# 123 = \x00{\x00 # 124 = \x00|\x00 # 125 = \x00}\x00
# 126 = \x00~\x00
```
## [](#header-2)Conversiones
### [](#header-3)Conversion de binario a decimal en Python
```py

```
### [](#header-3)Conversion de hexadecimal a decimal en Python
El codigo para hacer esta conversion es muy sencillo, hay que tener en cuenta que la lectura de la variable hex, debera ser un string.
Para este ejercicio, lo necesitaremos para imprimir los primeros 30 numeros y ultimos 30.
```py
s = '0xffa'
print(int(s,16))
```
### [](#header-3)Conversion de ascii a decimal en Python
Para este ejercicio, sera necesario convertir numeros de ascci a decimal, a partir del caracter 34. Los ascii en este programa se denotan por estar en la posicion numero 4 de nuestro penultimo registro.
```py
num=ord(char)
char=chr(num)

#Respuesta
>>> ord('a')
97
>>> chr(98)
'b'
```
### [](#header-3)Conversion de octal a decimal en Python
Para este ejercicio no sera necesario. Pero lo agrego por si se necesita algun dia. He buscado un codigo en internet y es el que les muestro a continuacion.
```py

def octal_a_decimal(octal):
    print(f"Convirtiendo el octal {octal}...")
    decimal = 0
    posicion = 0
    # Invertir octal, porque debemos recorrerlo de derecha a izquierda
    # pero for in empieza de izquierda a derecha
    octal = octal[::-1]
    for digito in octal:
        print(f"El número decimal es {decimal}")
        valor_entero = int(digito)
        numero_elevado = int(8 ** posicion)
        equivalencia = int(numero_elevado * valor_entero)
        print(
            f"Elevamos el 8 a la potencia {posicion} (el resultado es {numero_elevado}) y multiplicamos por el carácter actual: {valor_entero}")
        decimal += equivalencia
        print(f"Sumamos {equivalencia} a decimal. Ahora es {decimal}")
        posicion += 1
    return decimal


octal = input("Ingresa un número octal: ")
decimal = octal_a_decimal(octal)
print(f"El octal {octal} es {decimal} en decimal")
```
## [](#header-2)Filtrado de caracteres utilizando regex
Viene la parte mas interesante, el filtrado con regex, explicare 3 filtrados importantes que tenemos, en el primero obtendremos los dos ultimos registros que corresponden a los numeros que necesitamos, para mi regla de regex utilice una funcion que busca despues de ciertos caracteres (para escribir la barra '\' y sea interpretada tal cual en una regla regex, debera ser escrita doble vex '\\') para tomar los dos ultimos numeros de cada registro; y el bloque de codigo queda de la siguiente manera:
### [](#header-3)Filtro 1
El objetivo de este filtro es obtener los ultimos dos registros, los cuales se entienden por regex como "\w*.\\\w*", los requerimientos de los caracteres especiales hay que tenerlos en cuenta, tendremos problema con el caracter que es una comilla simple.
```py
#Obtenemos los 2 ultimos registros a utilizar
def get_hexa_number(hexa_result):
    hexa_result_search_filter = re.search(r"(?<=\\xd0\\x00\\x00\\xff\\xff\\x03\\x00\\x04\\x00\\x00\\x00\\)\w*.\\\w*",
                                          str(hexa_result))  # Resultado = t\x00
    if hexa_result_search_filter:
        print("La cadena filtrada es", hexa_result_search_filter)
        return hexa_result_search_filter
    else:
        #Si la cadena no esta presente, manejamos el error de esta manera
        print("No se han encontrado registros de respuesta en el filtro 1")
        
>>Respuesta

second_result = x01
third_result = x00
```
### [](#header-3)Filtro 2
Para este filtro, es necesario filtrar la posicion despues de la x, ya que nuestro programa no lee ese caracter. a continuacion los ejemplos
```py
def get_right_x(string):
    right_char = re.search(r"(?<=x\w)\w", str(string))
    if right_char:
        return right_char.group(0)
        print('right_result = ',righ_char)
    else:
        print("Sin valores para hexadecimal lado derecho")

>Respuesta

right_char = 0

def get_left_x(string):
    left_char = re.search(r"(?<=x)\w", str(string))
    if left_char:
        return left_char.group(0)
        print('left_result = ',left_char)
    else:
        print("Sin valores para hexadecimal lado izquierdo")
        
>>Respuesta

left_result = 1
```

## [](#header-2)Conclusiones
Una practica como estra, nos demuestra que podemos hacer lo que queramos con programacion, tiempo y un poco de paciencia.
Hemos aprendido la facilidad que tiene python para transformar ciertos caracteres en diferentes lenguajes que normalmente no utiliza una persona.