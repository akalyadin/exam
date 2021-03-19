#!/bin/bash
sudo apt install -y git apache2
sudo systemctl stop apache2
sudo apt install -y nginx
sudo mkdir /var/www/{8080,8081,8082}
sudo cp 8080/index.html /var/www/8080/
sudo cp 8081/index.html /var/www/8081/
sudo cp 8082/index.html /var/www/8082/
sudo cp 000-default.conf /etc/apache2/sites-available/
sudo cp ports.conf /etc/apache2/
sudo cp default.conf /etc/nginx/conf.d/
sudo cp default /etc/nginx/sites-available/
sudo cp upstream.conf /etc/nginx/conf.d/
sudo systemctl restart apache2.service
sudo systemctl restart nginx
