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

Давайте попробуем запустить процесс установки вручную, для удобства воспользуемся установкой через графический интерфейс.
В настройках виртуальной машины pxeclient нужно поменять графический контроллер на VMSVGA и добавить видеопамяти до 20 МБ или больше.
Нажимаем ОК, выходим из настроек ВМ и запускаем её.

Выбираем графическую установку

###Процесс установки:

![1_setup](https://user-images.githubusercontent.com/91377497/201866882-9546b675-6b0a-43ec-8ce3-ad5f9ede9800.jpg)

![2_setup](https://user-images.githubusercontent.com/91377497/201866912-5d13a1a3-03c6-4ae9-ac5b-0fe86c89d5d7.jpg)

![3_setup](https://user-images.githubusercontent.com/91377497/201866929-c8ef3cda-7be1-4e7f-819b-e43e08dccf35.jpg)

![4_setup](https://user-images.githubusercontent.com/91377497/201866941-a844f1d2-0853-4709-bfd7-430da4245664.jpg)

![5_setup](https://user-images.githubusercontent.com/91377497/201866958-90c0ba81-73cd-4a37-8f65-7708a500b81e.jpg)

###Загрузка ОС:

![1_start](https://user-images.githubusercontent.com/91377497/201867034-8fc38424-185c-4dde-bbfe-216a9fe20674.jpg)

![2_start](https://user-images.githubusercontent.com/91377497/201867077-cfe28bce-bfc0-4175-b0f7-a61ec83fcbff.jpg)

![3_start](https://user-images.githubusercontent.com/91377497/201867093-52569ce1-7048-496f-a26c-40203ff98d1d.jpg)

![4_start](https://user-images.githubusercontent.com/91377497/201867104-28e006fc-9718-4988-8992-e2e17485443f.jpg)

![5_start](https://user-images.githubusercontent.com/91377497/201867124-a702d739-749f-466f-ba6b-28faac8c6932.jpg)

![6_start](https://user-images.githubusercontent.com/91377497/201867140-4d0ef709-adb4-4132-908f-fd4f30167a18.jpg)



