---
layout: post
author: Sergio Salgado
---

## [](#header-2)Indice
Splunk es un SIEM con gran potencial, capaz de encontrar y responder a eventos con inteligencia artificial.

## [](#header-2)Consultas basicas
Podemos traernos los eventos, de la manera siguiente
```sql
index=* | fields - raw
```

El comando fields, es la clave para esta consulta. Con el signo negativo indicamos que queremos excluir de la información que se muestra, ese campo.

```sql
index=* | table raw _time
```
El comando table y fields son similares, su diferencia consiste en el formato en que se muestra la información

```sql
index=* | dedup action productID
```
El comando dedup nos ayuda a quitar los comandos duplicados
```sql
index=* | table clientip _time | sort clientip
```
El comando sort nos ayuda a ordenar la tabla, en este caso nos trae las IPs ordenadas en orden ascendente. Para ordenarlo de diferente manera, podemos agregar el signo negativo
```sql
index=* | table clientip _time | sort clientip | limit 10
```
El comando limit, nos ayudará para traer solamente la cantidad de filas que deseamos, en este caso 10 filas
```sql
index=* | table clientip _time | top clientip
```
El comando topnos dará el valor más repetido
```sql
index=* | table clientip _time | rare clientip
```
El comando topnos dará el valor menos repetido
```sql
index=* | table clientip _time | top clientip (showcount=False showperc=False)
```
En el comando top, rare salen los porcentajes y el count. Estos se pueden excluir agragando el false
```sql
index=* | table clientip _time | top clientip useother=True
```
El comando useother dentro del top o rare, nos da un panorama mas claro de lo que se está excluyento en el limit de resultados

### [](#header-3)COMANDOS DE TRANSFORMACION
Se usan para fines estadísticos con los resultados de tablas.

El primero que veremos es stats, que se apoya de una seriede funciones como "count", "dc", "sum", "avg", "list", "value"
Ejemplo con count
```sql
index=*sales* sourcetype="csv" | stats count by Region
```
En el siguiente ejemplo, se cuenta cuantas veces aparece el campo presente y despues cuenta los eventos en los que hizo la busqueda
```sql
index=*sales* sourcetype="csv" | stats count(action) as ActionEvents, count as "TotalEvents"
```
En el siguiente ejemplo, se extrae el número total de paises
```sql
index=*sales* sourcetype="csv" | stats dc(Country) as "Numero de paises" by "Order Priority"
```
En el siguiente ejemplo, se suma el total del campo que está después de la función sum
```sql
index=*sales* sourcetype="csv" | stats sum("Total Profit")
```
Esta misma consulta se puede separar para que la suma se haga por medio de otro campo
```sql
index=*sales* sourcetype="csv" | stats sum("Total Profit") by "Item Type"
```
En el siguiente ejemplo, se obtiene el promedio del campo que está después de la función avg
```sql
index=*sales* sourcetype="csv" | stats avg("Total Profit")
```
Esta misma consulta se puede usar para que se muestren los valores maximos y minimos en los campos de los eventos
```sql
index=*sales* sourcetype="csv" | stats avg("Total Profit"), min("Total Profit"), max("Total Profit")
```

En el siguiente ejemplo, se requiere listar dentro de una fila los productos vendidos por país
```sql
index=* | stats list("Item Type") by "Country"
```
El problema de la consulta anterior, es que te puede traer valores repetidos, para tener un resultado limpio sin duplicados, se usa la función values
```sql
index=* | stats values("Item Type") by "Country"
```