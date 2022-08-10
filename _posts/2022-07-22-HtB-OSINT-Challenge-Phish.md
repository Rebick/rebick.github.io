---
layout: post
author: Sergio Salgado
---

## [](#header-2)Introduccion

Para este challenge no hay nada para descargar, solamente nos da un dominio y nos dice que los clientes de secure-startup.com han estado recibiendo algunos emails de phishing muy convincentes.

Googleando un poco sobre phishing y spoofing de emails, nos encontramos con que existen 3 protocolos para mitigar este tipo de amenazas:

- Sender Policy Framework (SPF): Identifica, a través de los registros de nombres de dominio (DNS), a los servidores de correo SMTP autorizados para el transporte de los mensajes.
- Domain Keys Identified Mail (DKIM): Permite a una organización responsabilizarse del envío de un mensaje, de manera que éste pueda ser validado por un destinatario.
- Domain-Based Message Authentication, Reporting, and Conformance (DMARC): Diseñado para dar a los propietarios de dominios de correo electrónico la capacidad de proteger su dominio del uso no autorizado.

Existen varias herramientas que podemos utilizar, para este caso usaremos específicamente la <a href="https://toolbox.googleapps.com/apps/main/">herramienta</a> Check MX en la categoría “Verificar problemas de DNS”.

En la interfaz de la herramienta, ingresamos el dominio secure-startup.com y damos a “Realizar comprobaciones” dejando el campo de “Selector DKIM” vacío. Luego de un esperar menos de un minuto en este caso, obtendremos como resultado varios items, destacando los problemas de formato de las políticas DMARC y del registro SPF.

![Problemas descubiertos](/assets/images/CHALLENGES/OSINT/EasyPhish/problemas_descubiertos.png)

Dando click a estos problemas podremos ver la flag en 2 partes en formato HTB{Flag}, uniendolas tendremos ahora la flag

![Problemas descubiertos](/assets/images/CHALLENGES/OSINT/EasyPhish/flags.png)

![Problemas descubiertos](/assets/images/CHALLENGES/OSINT/EasyPhish/powned.png)