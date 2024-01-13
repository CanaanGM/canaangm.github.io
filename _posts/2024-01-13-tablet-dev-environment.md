---
layout: post
title: Android dev environment
date: 2024-01-13 05:56 +0300
categories: [setup]
tags: [android, tutorial]
---

**basically** an **on the go linux development environment** for your **tablet** and **phone**, i mainly use it to **sync data** between my devices using git, and some light dev work when i don't have access to my pc.

> Termux is an Android terminal emulator and Linux environment application that works directly with no rooting or setup required. [termux wiki](https://wiki.termux.com/wiki/Main_Page)


- download it from [F-Droid](https://f-droid.org/en/packages/com.termux/)
- it's [github repo](https://github.com/termux/termux-app)
- [wiki](https://wiki.termux.com/wiki/Main_Page)

> ports (change them for more security), most services ports are their normal ports prefixed with `80`

---

# Setting up
## storage access

```bash
termux-setup-storage
```

the folder location is `/data/data/com.termux/files/usr/`.

---

## Environment

> essential APPS 

```bash
pkg install git wget zip 
```
---

## programming languages

```bash
pkg install python3 rust 
```

## SSH
check [this](/posts/ssh-setup)

## [Obsidian](https://obsidian.md/) w/ git

since we installed git we can now sync notes folder thru a private repo

create it and set it up on your pc

in `.gitignore` depending on the plugins you use, either ignore the entire `.obsidian` or just what u don't wanna bother u everytime you create a new folder/file  :

> here's mine, i sync the themes and plugins so everywhere matches. 

```text
.obsidian/icons
.obsidian/workspace-mobile.json
.obsidian/workspace.json
.vscode
```

now you can add an *alias* to go immediately cd into the *notes* folder, or set a [cron job](https://github.com/termux/termux-app/discussions/3297) to auto pull/push at let's say midnight 

alias example:
- `alias <alias name>='cd /data/data/com.termux/files/home/storage/shared/<your notes folder>'`  

some stuff i usually add in termux `~/.zshrc` file:

```bash
alias update = "pkg update && pkg upgrade -y"
# for github
eval "$(ssh-agent) -s"
ssh-add ~/.ssh/[your github key]
# to start the ssh daemon
sshd
```

---

# Styling

## terminal theme

```bash
git clone https://github.com/adi1090x/termux-style.git
cd termux-style
./install
```

> i use `wild-cherry`

## styling nano

you can edit `~/.nanorc` and add these for qol improvements:

```text
set linenumbers
set numbercolor red
set titlecolor yellow
set mouse
set tabsize 2
set multibuffer
```


## zsh and oh my zsh
### install zsh

`pkg install zsh`

### oh my zsh

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

then change shell

`chsh`

###  syntax highlighting and autosuggestion

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/plugins/zsh-syntax-highlighting
```

add them in the plugin section

```text
plugins=( 
    # other plugins...
    zsh-autosuggestions
    zsh-syntax-highlighting
)
```

---

that's it, now you have a small dev environment in ur pocket or - *if your tablet is some what big* - on something that won't die in ~2 hrs xD 