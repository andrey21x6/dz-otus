# Docker

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- GNU bash, version 5.0.17(1)-release-(x86_64-pc-linux-gnu)

- Docker: 
```
Client: Docker Engine - Community
  Version:           20.10.18
  API version:       1.41
  Go version:        go1.18.6
  
Server:
  Engine:
  Version:          20.10.14
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.16.15
```

- Docker Compose version v2.11.2

# **Содержание ДЗ**

Разобраться с основами docker, с образа, эко системой docker в целом.
Описание ДЗ в документе.

# **Выполнение**

Создал свой кастомный образ nginx на базе alpine. 

Скачивание и запуск: 
```
docker pull andrey21x6/nginx-dz:1.0
```

Ссылка на Docker Hub: https://hub.docker.com/r/andrey21x6/nginx-dz/tags

Ссылка на GitH Hub: https://github.com/andrey21x6/dz-otus/tree/main/docker


### Разница между контейнером и образом:
На основе образа, запускаются контейнеры в любом количестве. Запущенный экземпляр образа - это контейнер.

### Можно ли в контейнере собрать ядро?

Предполагаю, что нет, так как контейнер использует ядро хостовой машины.

Вывод команды внутри контейнера:
```
uname -a
  Linux 2ed7aa411b70 5.15.0-46-generic #49~20.04.1-Ubuntu SMP Thu Aug 4 19:15:44 UTC 2022 x86_64 Linux
```

Вывод команды на хостовой машине:
```
uname -a
  Linux Ubuntu-20 5.15.0-46-generic #49~20.04.1-Ubuntu SMP Thu Aug 4 19:15:44 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
```

# **Дополнительное ДЗ**

Создал кастомные образы nginx и php, объединил их в docker-compose.
После запуска nginx показывает php info.

Ссылка на Docker Hub nginx: https://hub.docker.com/r/andrey21x6/docker-compose-nginx/tags
Ссылка на Docker Hub php: https://hub.docker.com/r/andrey21x6/docker-compose-php
Ссылка на GitH Hub: https://github.com/andrey21x6/dz-otus/tree/main/docker-compose


