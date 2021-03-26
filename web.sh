#!/bin/bash
#Проверка необходимого хоста (на слейв апач и нджинкс не ставим)
if [ `hostname` != 'slave' ]
    then
#        echo "Введите IP адрес SLAVE"
#        read slave

        sshpass -f 1pass.txt ssh a@192.168.122.7 'mkdir /home/a/Desktop/start'
        sshpass -f 1pass.txt scp start.sh a@192.168.122.7:/home/a/Desktop/start/run.sh
        echo "----------------------------
        Запусти скрипт run.sh на хосте slave (Desktop/start/), после окончания установки скрипт продолжит свое выполнение"

        i=0    
        #цикл для проверки что служба поднялась
        while [ $i -eq 0 ]
        do
            status=`sshpass -f 1pass.txt ssh a@192.168.122.7 'systemctl status mysql.service' 2>/dev/null | grep "active (running)" | wc -l 2>/dev/null`
            if [ $status -eq 0 ]
                then
                    sleep 2
                    echo -n .
                else
                    i=1
                    echo poweron
            fi
        done
        
        #Установка апача и нджинкса
        apt install -y git apache2
        systemctl stop apache2
        apt install -y nginx
        mkdir /var/www/{8080,8081,8082}
        cp 8080/index.html /var/www/8080/
        cp 8081/index.html /var/www/8081/
        cp 8082/index.html /var/www/8082/
        cp 000-default.conf /etc/apache2/sites-available/
        cp ports.conf /etc/apache2/
        cp default.conf /etc/nginx/conf.d/
        cp default /etc/nginx/sites-available/
        cp upstream.conf /etc/nginx/conf.d/
        systemctl restart apache2.service
        systemctl restart nginx
fi

#Ставим мускул
cd /tmp
wget https://dev.mysql.com/get/mysql-apt-config_0.8.15-1_all.deb
#надо закоментить sources list
cat /etc/apt/sources.list > ./temp.sources.list
#проверяем количество строк в файле sources.list
count_str=`wc -l /etc/apt/sources.list | cut -c '1-2'`
        #цикл для коментирования остальных источников
        for((i=1;i<=$count_str;i++))
        do
            j=$i"s/^/#/"
            k=$i"s/^#//"
            #убираем "#" у кого она есть (чтобы не было две "#" подряд)
            sed -i $k /etc/apt/sources.list
            #добавляем "#"
            sed -i $j /etc/apt/sources.list
        done
dpkg -i mysql-apt-config_0.8.15-1_all.deb
echo "deb http://repo.mysql.com/apt/debian stretch InRelease" | tee -a /etc/apt/sources.list
echo "deb http://deb.debian.org/debian/ stretch main contrib non-free" | tee -a /etc/apt/sources.list
cd /tmp
wget https://dl.astralinux.ru/astra/testing/orel/repository/pool/main/d/debian-archive-keyring/debian-archive-keyring_2017.5_all.deb
apt install ./debian-archive-keyring_2017.5_all.deb
apt-get update
apt-get install -y mysql-server
#коментим все в sources.list кроме репы астры
count_str=`wc -l /etc/apt/sources.list | cut -c '1-2'`
        #цикл для коментирования остальных источников
        for((i=1;i<=$count_str;i++))
        do
            j=$i"s/^/#/"
            k=$i"s/^#//"
            #убираем "#" у кого она есть (чтобы не было две "#" подряд)
            sed -i $k /etc/apt/sources.list
            #добавляем "#"
            sed -i $j /etc/apt/sources.list
        done
cat ./temp.sources.list | tee -a /etc/apt/sources.list
rm ./temp.sources.list

#aslave=a@`$slave`
#rootssh=`sshpass -f 1pass.txt ssh root@192.168.122.7 'cat /etc/ssh/sshd_config | grep PermitRootLogin | grep yes' | wc -l`
#if [ $rootssh

if [ `hostname` != 'slave' ]
    then
        wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch |  apt-key add -
        echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
        apt update && apt install elasticsearch
        systemctl daemon-reload
        systemctl enable elasticsearch.service
	systemctl start elasticsearch.service
        apt install curl
#        rm /etc/elasticsearch/elasticsearch.yml
#        cp elasticsearch.yml /etc/elasticsearch/
#        wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
#        echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
#        apt update && apt install kibana
#        systemctl daemon-reload
#        systemctl enable kibana.service
#        systemctl start kibana.service
#        rm /etc/kibana/kibana.yml
#        cp kibana.yml /etc/kibana/
#        apt install logstash
#        systemctl enable logstash.service        
#        cp input.conf /etc/logstash/conf.d
#        cp output.conf /etc/logstash/conf.d
#        cp filter.conf /etc/logstash/conf.d
#        systemctl start logstash.service
#        curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.11.0-amd64.deb
#        dpkg -i filebeat-7.11.0-amd64.deb
#        rm /etc/filebeat/ilebeat.yml
#        cp filebeat.yml /etc/filebeat/
#        systemctl start filebeat
#        systemctl enable filebeat
#        apt install xdg-utils
#        xdg-open http://127.0.0.1:80
#        xdg-open http://127.0.0.1:5601
fi
