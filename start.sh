#!/bin/bash
sudo apt install -y git
git init
git config --global user.email "akalyadin@astralinux.ru"
git config --global user.name "AlexeyKalyadin"
git remote add origin https://github.com/akalyadin/exam.git
git pull https://github.com/akalyadin/exam.git main
#ssh-keygen -t rsa -N "" -f ./id_rsa
#cat id_rsa.pub
./web.sh
