# DHCP, PXE

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.5
- Guest OS: 8.4.2105
- VirtualBox: 6.1.40
- Vagrant: 2.3.2
- Ansible [core 2.13.6]
- Python version = 3.8.10
- jinja version = 3.1.2

# **Содержание ДЗ**

Цель:

Отрабатываем навыки установки и настройки DHCP, TFTP, PXE загрузчика и автоматической загрузки


Описание/Пошаговая инструкция выполнения домашнего задания:

- Следуя шагам из документа https://docs.centos.org/en-US/8-docs/advanced-install/assembly_preparing-for-a-network-install установить и настроить загрузку по сети для дистрибутива CentOS8.
В качестве шаблона воспользуйтесь репозиторием https://github.com/nixuser/virtlab/tree/main/centos_pxe.

- Поменять установку из репозитория NFS на установку из репозитория HTTP.

- Настройить автоматическую установку для созданного kickstart файла (*) Файл загружается по HTTP.

- Aвтоматизировать процесс установки Cobbler cледуя шагам из документа https://cobbler.github.io/quickstart/.

# **Выполнение ДЗ**

Скачиваем файлы, указанные в домашнем задании. Внесём изменения в загруженный Vagrantfile
```
server.vm.box = 'centos/8.4'
pxeclient.vm.box = 'centos/8.4'
```

меняем на

```
server.vm.box = 'bento/centos-8.4'
pxeclient.vm.box = 'bento/centos-8.4'
```

Удаляем запись
```
server.vm.disk :disk, size: "15GB", name: "extra_storage1"
```

Добавляем (раскоментируем) запись, так как будем использовать HTTP
```
server.vm.network "forwarded_port", guest: 80, host: 8081
```

Блок настройки PXE-сервера с помощью bash-скрипта удаляем, так как будем использовать Ansible для настройки хоста

Для настройки хоста через Ansible, нам потребуется дополнительный сетевой интефейс для pxeserver
```
server.vm.network :private_network, ip: "192.168.50.10", adapter: 3
```

После внесения всех изменений запускаем наш стенд
```
vagrant up
```

Выполнение команды закончится с ошибкой, так как на pxeclient настроен на загрузку по сети

Теперь можем приступить к настройке pxeserver
Для настроки хоста с помощью Ansible нам нужно создать несколько файлов и прописать необходимые параметры:
```
ansible.cfg
host
provision.yml
main.yml - в каталоге defaults
default.j2 - в каталоге templates
dhcpd.j2 - в каталоге templates
pxeboot.j2 - в каталоге templates
```

Файл CentOS-8.4.2105-x86_64-dvd1.iso сначало скачал вручную на хостовую машину, а затем с помощью ansible-playbook скопировал на PXE-сервер (скачивалось часов 10)

Давайте попробуем запустить процесс установки вручную, для удобства воспользуемся установкой через графический интерфейс.
В настройках виртуальной машины pxeclient нужно поменять графический контроллер на VMSVGA и добавить видеопамяти до 20 МБ или больше.
Нажимаем ОК, выходим из настроек ВМ и запускаем её.

Выбираем графическую установку

### Процесс установки:

![1_setup](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/1_setup.jpg)

![2_setup](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/2_setup.jpg)

![3_setup](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/3_setup.jpg)

![4_setup](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/4_setup.jpg)

![5_setup](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/5_setup.jpg)

### Загрузка ОС:

![1_start](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/1_start.jpg)

![2_start](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/2_start.jpg)

![3_start](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/3_start.jpg)

![4_start](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/4_start.jpg)

![5_start](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/5_start.jpg)

![6_start](https://github.com/andrey21x6/dz-otus/blob/main/DHCP_PXE/scrin/6_start.jpg)



