---
layout: post
author: Sergio Salgado
---

1. Instalacion de los paquetes

```s
sudo apt install build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev
```

* * *

2. Instalacion de bspwn y sxhkd

```s
git clone https://github.com/baskerville/bspwm.git
git clone https://github.com/baskerville/sxhkd.git

cd bspwm
make
sudo make install
cd ../sxhkd
make sudo make install

sudo apt install bspwm
```

* * *

3. Cargamos bspwm y sxhkd ficheros de ejemplo:

```s
mkdir ~/.config/bspwm
mkdir ~/.config/sxhkd

cp /bspwm/examples/bspwmrc ~/.config/bspwm/
chmod +x ~/.config/bspwm/bspwmrc

cp sxhkd/examples/background_shell/sxhkdrc ~/.config/sxhkd/
chmod +x ~/.config/sxhkd/sxhkdrc
```

* * *

4. Abrimos el sxhkdrc y configuramos el tipo de terminal asi como algunos key bindings:

```s
nano ~/.config/sxhkd/sxhkdrc
```

```s
#------------------
#
#wn independient hotkeys
#

# terminal emulator
super + Return
        gnome-terminal


```