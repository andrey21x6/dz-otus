# docker

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.4
- GNU bash, version 5.0.17(1)-release-(x86_64-pc-linux-gnu)

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


