#!/bin/bash
echo "Введите IP адрес MASTER"
read master
echo "Введите IP адрес SLAVE"
read slave
if [ `whoami` != root ]
    then
        echo "Вы не являетесь привелигированным пользователем,выполните  sudo -i"
        exit 0
fi
slave_ping=`ping -c 3 $slave | grep ttl | wc -l`
if [ $slave_ping -ne 3 ]
    then
        echo "Отсутствует пинг до хоста slave"
        exit 0
fi
apt install -y git sshpass apache2
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
echo "deb http://repo.mysql.com/apt/debian stretch InRelease" | tee /etc/apt/sources.list
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
