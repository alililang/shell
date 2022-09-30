#! /bin/bash
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
plain='\033[0m'
#set config
ip="# c.NotebookApp.ip = 'localhost'"
allow="# c.NotebookApp.allow_remote_access = False"
open="# c.NotebookApp.open_browser = True"
port="# c.NotebookApp.port = 8888"
part=.jupyter/jupyter_notebook_config.py

echo -e "${green}#########################################"
echo -e "${green}#                                       #"
echo -e "${green}#         jupyter一键部署脚本           #"
echo -e "${green}#  此脚本由aliase@aliyun.com维护        #"
echo -e "${green}#           此脚本仅用于学习            #"
echo -e "${green}#                                       #"
echo -e "${green}#########################################${plain}"

apt-get install libffi-dev
apt install python3-pip -y
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple jupyter
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple jupyterlab
jupyter notebook --generate-config -y

sed -i s/$ip/"c.NotebookApp.ip = '0.0.0.0'"/g $part
sed -i s/$allow/"c.NotebookApp.allow_remote_access = True"/g $part
sed -i s/$open/"c.NotebookApp.open_browser = False"/g $part
sed -i s/$port/"c.NotebookApp.port = 8888"/g $part

pip3 install jupyter_contrib_nbextensions -i https://pypi.tuna.tsinghua.edu.cn/simple
pip3 install jupyter_nbextensions_configurator -i https://pypi.tuna.tsinghua.edu.cn/simple
jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user
jupyter lab
apt -y install ufw 
ufw enable
ufw allow 8888
jupyter notebook --allow-root > /var/log/jupyter.log 2>&1 &
#nohup jupyter notebook --allow-root > /var/log/jupyter.log 2>&1 &
