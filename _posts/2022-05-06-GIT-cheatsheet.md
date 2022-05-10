---
title: GIT cheatsheet
published: True
---

# [](#header-1)GIT cheatsheet

## [](#header-2)Indice
- <a href="#introduccion">Introduccion</a>
- <a href="#desarrollo">Desarrollo</a>

## [](#header-2)<a id="introduccion">Introduccion</a>
Es necesario para la eficiencia de los proyectos, tener una correcta gestion de las versiones que se han realizado, para poder documentar el funcionamiento actual del trabajo realizado y poder medir la eficiencia del trabajo. Tambien comunmente se utiliza para poder partir desde un bosquejo donde los requerimientos sean similares y no tener que empezar de ceros. Este es mi primera documentacion, y quizas falten detalles para indagar en los servicios que se han encontrados, ya que procure ser directo para llegar al resultado de las flags.

## [](#header-2)<a id="desarrollo">Desarrollo</a>

```
git init    #Inicia el proyecto en la ubicacion actual

git remote add origin [clone LINK]      #Para especificar el repositorio donde trabajaremos

git pull origin master      #Para actualizar el repositorio

git merge origin/master     #Para sincronizar ramas

npm version minor	#Este comando nos pone la version v0.1.0 para el tag (Siguiente comando)

git tag 		#nos mostrara ahora que estamosn en la version establecida con el comando anterior

git push --tags && git push origin master	#Este comando nos servira para subir los tags y cambios hechos para git

git branch 	#Lista las ramas

git checkout -b 01-base-proyecto	#Nueva rama del proyecto creada

```