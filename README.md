### Пример репликации СУБД postgres  
- Установить multipass (**оркестратор виртуальных машин**): https://snapcraft.io/install/multipass/ubuntu  
- Создать две виртуальные машины командами:  

> * multipass launch -c 2 -m 2G -d 10G -n manager  
> * multipass launch -c 2 -m 2G -d 10G -n vm-1  

- Проверить, что машины созданы следующей командой:

> multipass ls  

Сервер **vm-1** это рабочий сервер, а **manager** - главный сервер, управляющий будущим кластером. Если сервера не имеют статус Running, то попробуйте запустить их командой:  

> multipass start vm-1 manager  

**ВАЖНО! После окончания работы с виртуальными серверами лучше будет, если вы завершите их работу командой:**  

> multipass stop vm-1 manager  

**После перезагрузки вашего ПК, виртуальные сервера не будут запущены и не будут занимать ресурсы вашего ПК.**  

- Зайти на manager машину. Вход на manager машину:  

> multipass shell manager  

И установить на нем Docker (https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-ru). Тоже самое нужно сделать и на машине vm-1.

- Сменить пароль ubuntu пользователя, на пример на '123' (без кавычек). Имя пользователя виртуального сервера здесь  **ubuntu**:  

> sudo passwd ubuntu  

Придумайте пароль и подтвердите его. Он вам понадобится при выполнении **sudo** операций. Выйти из виртуальной машины можно, введя команду **exit** прямо в командной оболочке виртуальной машины.

- Настройка команды Docker без sudo. Команды по порядку (обратный слэш удалите):

> sudo usermod -aG docker ${USER}  
> su - ${USER}  
> sudo usermod -aG docker ubuntu  

Теперь команды докера должны вызываться без прав суперпользователя **sudo**
> docker ps

- На машине **manager** выполните инициализацию Docker Swarm кластера:  

> docker swarm init  

Завершить работу класетра и удалить его можно так:  ``docker swarm leave --force ``  

- Зайти на машину vm-1 запустить там результат команды ``docker swarm init``. Будет что-то примерно такое:  

> docker swarm join --token SWMTKN-1-5dvwq493pyjgeqk9hd9af16uoiqwjnwzmu1gc709ib2t2180q0-c7ksynsfj1zg05w56lph3wlju 10.200.64.72:2377  

Теперь машина manager является главным сервером, vm-1 - рабочим, то есть manager и worker. На manager можно увидеть созданные узлы (nodes):  

> docker node ls  

Ответ (пример):  
ubuntu@manager:~$ docker node ls  
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION  
vsh48tutvmni5cfgdmihyf231 *   manager    Ready     Active         Leader           24.0.7  
bacigz8sw60ksaw7rvmdsmsbm     vm-1       Ready     Active                          24.0.7  

- Снова перейти на manager машину, если терминал был с ней закрыт закрыт:

> multipass shell manager  

- Далее, в текущем или ином каталоге вызвать команду клонирования проекта:  

> * git clone git@github.com:Promiteus/docker-swarm-postgre-replication.git   
> * cd docker-swarm-postgre-replication

- Вызвать команду развертывания конфигурации docker-stack.yml:  

> docker stack deploy --with-registry-auth -c docker-stack.yml rep  

- Если все успешно, то команда ``docker service ls`` покажет запущенные сервисы. Обычно запуск происходит не сразу, так как образы еще не были загружены на сервер.  

- Вызовите команду из хост машины (вне виртуальных машин) для выяснения IPv4 адреса виртуальной машины manager:  

>  multipass info manager  

- После, по полученому IP адерсу зайти в браузер и убедиться, как приложение visualizer отображает сервисы по вритуальным машинам. Перейти http://10.200.64.72:8080/  
У вас будт свлой IP.  
  
- Чтобы войти в панель управлния СУБД вставьте в браузерную строку ссылку: http://10.200.64.72:8089/?pgsql=postgres_master&username=sa&db=docker_replica&ns=public  

- А теперь загрузим страны и города в postgres-master СУБД сервис. Делается это на manager виртуальной машине в каталоге проетка docker-swarm-postgres-replica:  

> ./scripts/cities/prod/init-ru-db.sh  

Проверим, что таблицы и данные в них появились по ссылке: http://10.200.64.72:8089/?pgsql=postgres_master&username=sa&db=docker_replica&ns=public  
Проверить такие же данные в репликах: http://10.200.64.72:8089/?pgsql=postgres_replica&username=sa&db=docker_replica&ns=public  

