---
layout: post
author: Sergio Salgado
---

## [](#header-2)Introduccion
Para este desafio, se nos pregunta si podemos encontrar algo para infiltrarnos en 'Evil Corp LLC', encontrar social media para ver si podemos encontrar informacion util.

Se nos muestra un perfil de Linkedin, con una flag posible.Pero no es, al mismo tiempo se observa un sitio web que podriamos ver para recopilar informacion.

![Problemas descubiertos](/assets/images/CHALLENGES/OSINT/Infiltration/linkedin.png)

Si abrimos la pseudoconsola que esta en home no podremos ejecutar comandos, y solo se nos abriran dialogos para unirnos a la FSOCIETY.

Si abrimos la terminal y hacemos un ls podremos ver algunos archivos ocultos si les hacemos un open nombre.del.archivo en el hay imagenes y un pdf.

Se intento hacer un exiftool al PDF que se muestra en el escritorio tampoco veremos nada y en las imagenes no hay nada interesante.

Decidi regresar al Linkedin para listar a los empleados registrados aqui. Parecia que dentro de una de las personas habia una parte de la flag, pero en verdad no era nada.

Regresando a la busqueda de google, encontramos a un perfil de instagram que podria considerarse como empleado, resulta que en una de las fotos donde se ve una computadora y una credencial de trabajo, se encuentra la flag.