# Сетевые пакеты. VLAN LACP

# **Prerequisite**

- Host OS: Ubuntu Desktop 20.04.5
- Guest OS: CentOS 7.8.2003
- VirtualBox: 6.1.40
- Vagrant: 2.3.2

# **Содержание ДЗ**

- В Office1 в тестовой подсети появляется сервера с доп интерфесами и адресами в internal сети testLAN

	-- testClient1 - 10.10.10.254
	
	-- testClient2 - 10.10.10.254
	
	-- testServer1- 10.10.10.1
	
	-- testServer2- 10.10.10.1
	
- Равести вланами

	-- testClient1 <-> testServer1
	
	-- testClient2 <-> testServer2
	
- Между centralRouter и inetRouter "пробросить" 2 линка (общая inernal сеть) и объединить их в бонд

- Проверить работу c отключением интерфейсов

# **Выполнение ДЗ**

Описание команд и настроек находятся в файлах Vagrantfile и playbook.yml

Запускаем стенд
```
vagrabt up
```

После запуска стенда, открывает шесть окон терминалов для удобства и подключаемся к ВМ
```
vagrant ssh testServer1
vagrant ssh testClient1
vagrant ssh testServer2
vagrant ssh testClient2
vagrant ssh inetRouter
vagrant ssh centralRouter
```

На ВМ testServer1, testClient1, testServer2, testClient2 введём команду ip a и посмотрим, что получилось
```
ip a
```

![ip_a_testServer1](https://user-images.githubusercontent.com/91377497/207095925-bbd31d20-4394-4b45-a8b7-edf1e0dbde57.jpg)

![ip_a_testClient1](https://user-images.githubusercontent.com/91377497/207096004-9049be3b-1e89-40bf-9dcf-9536e63bd40f.jpg)

![ip_a_testServer2](https://user-images.githubusercontent.com/91377497/207096046-79eea531-c739-4404-8d81-d8920d1dc549.jpg)

![ip_a_testClient2](https://user-images.githubusercontent.com/91377497/207096102-5ba4e9c5-48be-40ed-9b19-23357a74ab1d.jpg)

На inetRouter и centralRouter, нужно зайти в sudo, выполнить перезапуск сетевой службы (в playbook.yml перезапуск прописан, но видимо одного раза мало) и команду ip a
```
sudo -i
systemctl restart network
ip a
```

![ip_a_inetRouter](https://user-images.githubusercontent.com/91377497/207096215-dc7c5faf-8704-4d8e-8b50-6896508b65e2.jpg)

![ip_a_centralRouter](https://user-images.githubusercontent.com/91377497/207096237-8c5250ac-ee45-413d-99c9-d5b8243e2f58.jpg)

На testClient1 запустим tcpdump (VLAN 100)
```
sudo -i
tcpdump -nvvv -ieth1
```

В на testServer1 запустим пинг на testClient1 (VLAN 100)
```
ping -c 4 10.10.10.254
```

![tcpdump_testClient1](https://user-images.githubusercontent.com/91377497/207096341-72ebbaa4-a118-4b2b-942b-e897c4376546.jpg)

Делаем тоже самое на VLAN 101

На testClient2 запустим tcpdump (VLAN 101)
```
sudo -i
tcpdump -nvvv -ieth1
```

В на testServer2 запустим пинг на testClient2 (VLAN 101)
```
ping -c 4 10.10.10.254
```

![tcpdump_testClient2](https://user-images.githubusercontent.com/91377497/207096540-bf401bab-a052-427e-9b0d-1d27d445339e.jpg)

На inetRouter проверяем пинг
```
sudo -i
ping -c 4 192.168.255.2
```

![ping_1_inetRouter](https://user-images.githubusercontent.com/91377497/207096602-618fb170-da76-4823-ae3a-74369acb8d1b.jpg)

Отключаем один интерфейс и снова пингуем
```
ip link set eth1 down
```

![ping_2_inetRouter](https://user-images.githubusercontent.com/91377497/207096634-7c51a895-5332-4263-83ec-3878f9805942.jpg)

### ![#008000](https://placehold.co/15x15/008000/008000.png) ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) ![#1589F0](https://placehold.co/15x15/1589F0/1589F0.png)
### Благодарю за проверку!
