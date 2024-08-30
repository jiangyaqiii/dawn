#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 检查并安装 Node.js 和 npm
function install_nodejs_and_npm() {
    if command -v node > /dev/null 2>&1; then
        echo "Node.js 已安装"
    else
        echo "Node.js 未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    if command -v npm > /dev/null 2>&1; then
        echo "npm 已安装"
    else
        echo "npm 未安装，正在安装..."
        sudo apt-get install -y npm
    fi
}

# 检查并安装 PM2
function install_pm2() {
    if command -v pm2 > /dev/null 2>&1; then
        echo "PM2 已安装"
    else
        echo "PM2 未安装，正在安装..."
        npm install pm2@latest -g
    fi
}


# 节点安装功能
function install_node() {
    install_nodejs_and_npm
    install_pm2

    apt install python3-pip
    
    pip3 install pillow -i https://mirrors.aliyun.com/pypi/simple/
    pip3 install ddddocr -i https://mirrors.aliyun.com/pypi/simple/
    pip3 install requests -i https://mirrors.aliyun.com/pypi/simple/
    pip3 install loguru -i https://mirrors.aliyun.com/pypi/simple/


    # 获取用户名
    # read -r -p "请输入用户名: " DAWNUSERNAME
    # export DAWNUSERNAME=$DAWNUSERNAME

    # 获取密码
    # read -r -p "请输入密码: " DAWNPASSWORD
    # export DAWNPASSWORD=$DAWNPASSWORD
    
    echo $DAWNUSERNAME:$DAWNPASSWORD > password.txt

    wget -O dawn.py https://raw.githubusercontent.com/b1n4he/DawnAuto/main/dawn.py
    # 更新和安装必要的软件
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev lz4 snapd

    # pm2 start dawn.py
    nohup python3 dawn.py &
}

install_node

