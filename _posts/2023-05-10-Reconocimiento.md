---
layout: post
author: Sergio Salgado
---

## [](#header-2)Introduccion

Agregando la opcion -D IP1,IP2,ME, podemos confundir a la victima haciendo pasar el escaneo por diferentes tipos de IP de origen. Se pueden usar IPs aleatorias si se pone la variable RND. Quedaría de la siguiente forma:
```s
sudo nmap -sS -Pn -F -D RND,RND,ME,RND,RND $IP
```

Tambien se puede usar de la forma:
```s
sudo nmap -sS -Pn -F -D RND:3 $IP
```

Tambien se puede spoofear la MAC Address con el comando --spoof-mac 00:02:DC, esto solo funcionaria en caso de que se comparta el mismo segmento de red con la MAC especificada y así poder capturar los paquetes de destino hacia este
Para hacer spoof de la IP tenemos el comando -S $IP y también sirve solo si estamos en el mismo segmento de red.

Para usar puertos que quizas sean permitidos solamente en la red, podemos especificarle a nmap que lo use para realizar el escaneo, de la forma siguiente
```s
nmap -sS -Pn -g 8080 -F MACHINE_IP 
nmap -sS -Pn --source-port 8080 -F MACHINE_IP
```

Fragmentación de paquetes con 8 bytes de data.
Una de las formas sencillas de realizarlo es con la opción "-f" de nmap, ya que si se ejecuta de manera predeterminada, se mandará con 24 bytes. 
```s
nmap -sS -Pn -f -F MACHINE_IP
```

La misma fragmentación, pero con 16 bytes de data es posible tambien agregando una f al comando anterior, para que quede de la manera siguiente:
```s
nmap -sS -Pn -f -F MACHINE_IP
```

Fragmentación de paquetes de acuerdo estableciendo una unidad maxima de transmision (MTU)
al comando se le agrega la opción "--mtu $VALUE", el cual especifica el numero de bytes por paquete de IP. En otras palabras el tamaño del encabezaado de la IP no viene incluido. Este valor deberá ser siempre un múltiplo de 8.
```s
nmap -sS -Pn --mtu 8 -F MACHINE_IP
```

Generacion de paquetes con tamaño especifico.
Es posible ser más evasivos contra un IDS o IPS estableciendo un tamaño especifico de paquetes. Con nmap, la opcion es "--data-length $VALUE" y nuevamente $VALUE deberá ser un multiplo de 8.
```s
nmap -sS -Pn --data-length 64 -F MACHINE_IP
```

Especificando ttl
nmap nos da más controles sobre la modificacion de los encabezados de IP. Unos de estos campos que se pueden controlar son los TTL. La opcion es "--ttl $VALUE", esta opcion es util si piensas que tu ttl de default expone actividad de escaneo de puertos.
```s
nmap -sS -Pn --ttl 81 -F MACHINE_IP
```

Usando una checksum erronea
Algunos sistemas tiran los paquetes al contenerse una erronea chcksum, la opcion en nmap es: "--badsum".
```s
nmap -sS -Pn --badsum -F MACHINE_I
```

Comando final a intentar
```s
nmap -sS -Pn --badsum -F 
```

Script automatizado para extraer los puertos hallados
```s
target=10.10.10.245 && ports=$(nmap -p- --min-rate=1000 -Pn -T4 $target | grep '^[0-9]' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//) &&
nmap -p$ports -Pn -sC -sV $target
```
