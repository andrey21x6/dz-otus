# Загрузка системы

# **Prerequisite**
- Host OS: Ubuntu Desktop 20.04.4
- Guest OS: Cent OS 7.5.1804
- VirtualBox: 6.1.36
- Vagrant: 2.3.0-1

# **Содержание ДЗ**

* Попасть в систему без пароля несколькими способами
* Установить систему с LVM, после чего переименовать VG
* Добавить модуль в initrd


# **Выполнение**

### Попасть в систему без пароля несколькими способами

Запускаем Vagrant и заходим в виртуалку
```
vagrant up
vagrant ssh
```

Инициализирует root и задаём ему пароль
```
sudo passwd root
```

Перезагружаем систему и при показе меню нажимаем клавишу е
```
sudo reboot
```

Ищем строку начинающуюся с linux16 и дописываем в конце rd.break и нажимаем сочетание клавиш Сtrl+x

Когда загрузится, выполняем команду перемонтирования, чтобы sysroot сделать записываемым
```
mount -o remount,rw /sysroot
```

Затем выполняем команду входа в chroot
```
chroot /sysroot
```

Далее меняем пароль root как обычно
```
passwd root
```

Создаём файл переиндексации при загрузки системы
```
touch /.autorelabel
```

Выполняем команду выхода из chroot
```
exit
```

Выполняем команду перемонтирования, чтобы sysroot сделать RO
```
mount -o remount,ro /sysroot
```

Далее перезагружаемся и заходим под новым паролем
```
reboot
```

Другие способы отличаются установкой других параметров в конфигурацию загрузки. А именно:
* В строке начинающуюся с linux16, дописываем в конце init=/bin/sh и нажимаем сочетание клавиш Сtrl+x и выполняем mount -o remount,rw / и т. д. по аналогии
* В строке начинающуюся с linux16, заменāем ro на rw init=/sysroot/bin/sh и нажимаем сочетание клавиш Сtrl+x


### Установить систему с LVM, после чего переименовать VG


Смотрим, какие volume group имеются
```
vgscan

  Reading volume groups from cache.
  Found volume group "VolGroup00" using metadata type lvm2
```

Переименовываем volume group "VolGroup00" на "VolGroup01"
```
vgrename VolGroup00 VolGroup01

 Volume group "VolGroup00" successfully renamed to "VolGroup01"
```

Смотрим, что получилось
```
vgscan

  Reading volume groups from cache.
  Found volume group "VolGroup01" using metadata type lvm2
```

Так же переименовываем в следующих файлах:
```
sed -i -e "s/VolGroup00/VolGroup01/g" /etc/fstab
sed -i -e "s/VolGroup00/VolGroup01/g" /etc/default/grub
sed -i -e "s/VolGroup00/VolGroup01/g" /boot/grub2/grub.cfg
```

Пересоздаем initrd image, чтобы он знал новое название Volume Group
```
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)

...
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
```

### Добавить модуль в initrd

Создаём каталог
```
mkdir /usr/lib/dracut/modules.d/01test
```

Создаём файл и добавляем в него код

```
vi /usr/lib/dracut/modules.d/01test/module-setup.sh

#!/bin/bash

check() {
    return 0
}

depends() {
    return 0
}

install() {
    inst_hook cleanup 00 "${moddir}/test.sh"
}
```

Создаём файл и добавляем в него код
```
vi /usr/lib/dracut/modules.d/01test/test.sh

#!/bin/bash

exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
cat <<'msgend'
Hello! You are in dracut module!
 ___________________
< I'm dracut module >
 -------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
msgend
sleep 10
echo " continuing...."
```

Делаем исполняемыми
```
chmod +x /usr/lib/dracut/modules.d/01test/module-setup.sh
chmod +x /usr/lib/dracut/modules.d/01test/test.sh
```

Пересобирём образ initrd
```
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)

...
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
```

Проверяем
```
lsinitrd -m /boot/initramfs-$(uname -r).img | grep test

test
```

Перезагружаемся
```
reboot
```

# **Результаты**

Полученный в ходе работы `Vagrantfile` помещен в публичный репозиторий:
- **GitHub** - https://github.com/andrey21x6/dz-otus/tree/main/system_boot

Получили доступ к системе, не зная пароля root.

Получили переименованный volume group.

Во время загрузки системы будет виден пингвин.
