# docker-hub
***
#0 
в virtualbox нужно сделать проброс портов 8081 и 8083 и 2222 на виртуалку ???????

#1 
если нужно собрать билд с нуля, делаем это командой docker build -t project_name .
но проще, слить готовый билд с хаба

    docker pull chepil/rna

#1.1 
допустим, что наша папка, с проектом, которая будет внутри /app лежит на локальной машине, в папке /Users/chepil/development/beauit/smart-narod-mobile-app
Нужно ее синхронизировать с app, для этого используем --mount 

    export APP_FOLDER="/Users/chepil/development/company/project-name-mobile-app"

#2 
запускаем докер контейнер

    docker run -d -it --privileged --net=host \
        --hostname sn --name sn \
	    --mount type=bind,source=$APP_FOLDER,target=/app \
	    chepil/rna 
	

#
создаем внутри докера дирректорию для ssh и копируем в нее свой id_rsa.pub ключ, чтобы иметь доступ по ssh (если у вас нет файла /Users/user/.ssh/id_rsa.pub на хост машине, нужно запустить ssh-keygen) 

    (docker exec -u 0 -i sn bash -c "mkdir /root/.ssh && chmod 700 /root/.ssh && touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys") && \
    (docker exec -u 0 -i sn bash -c "cat >> /root/.ssh/authorized_keys") < ~/.ssh/id_rsa.pub 

#
если вдруг нужно будет зайти в docker контейнер, без всякого ssh, можно использовать команду: docker exec -u 0 -it sn bash

для подключения по ssh к докер контейнеру - (в первый раз ответить yes) -

    ssh root@localhost -p 2222 

также, можно добавить в свой config у ssh несколько строчек, 
чтобы сразу подключаться например командой ssh sn (вместо ssh root@localhost -p 2222)
например: в моем конфиге - /Users/chepil/.ssh/config есть такие строчки:

    Host sn
	    HostName 127.0.0.1
	    User root
	    Port 2222

#
Далее, нужно собрать node_modules

    cd /app
    npm install 

#7 
на mac os x
если ранее запускался adb, нужно прибить сервер

    adb kill-server

затем нужно сделать проброс порта 5555 в эмулятор - 
    
    lsof -iTCP -sTCP:LISTEN -P | grep 'emulator\|qemu'
    cd /tmp
    mkfifo backpipe
    nc -kl 5555 0<backpipe | nc 127.0.0.1 5555 > backpipe

#8
с линукса
    
    cd /app
    adb connect 192.168.99.1:5555

(смотрим в эмулятор, должно всплыть окно, на запрос разрешения коннектиться)

    react-native start

вторая консоль на линуксе

    cd /app
    ./run

#9
на эмуляторе, установить debug порт 192.168.99.101:8081








