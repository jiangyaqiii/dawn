# 安装特定版本 Go 的函数
REQUIRED_GO_VERSION="1.22.3"
CURRENT_GO_VERSION=$(go version 2>/dev/null | awk -F ' ' '{print $3}' | sed 's/go//')

if [ "$CURRENT_GO_VERSION" != "$REQUIRED_GO_VERSION" ]; then
    echo "当前 Go 版本 ($CURRENT_GO_VERSION) 不符合要求 ($REQUIRED_GO_VERSION)。正在安装正确版本..."
    wget -q https://golang.org/dl/go$REQUIRED_GO_VERSION.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go$REQUIRED_GO_VERSION.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo "Go $REQUIRED_GO_VERSION 安装完成。"
    source ~/.bashrc
else
    echo "Go 已经是正确版本 ($REQUIRED_GO_VERSION)。"
fi

echo "更新包列表..."
sudo apt update

install_go

if ! command -v git &> /dev/null; then
    echo "Git 未安装，开始安装..."
    sudo apt install -y git
else
    echo "Git 已经安装，跳过安装。"
fi

echo "克隆项目..."
if [ -d "Dawn-main" ]; then
    echo "Dawn-main 目录已存在，跳过克隆。"
else
    git clone https://github.com/sdohuajia/Dawn-main.git
fi
cd Dawn-main || { echo "无法进入 Dawn-main 目录"; exit 1; }

if [ ! -f "conf.toml" ]; then
    echo "配置文件 conf.toml 不存在，请确保文件存在并重新运行脚本。"
    exit 1
fi

echo "下载 Go 依赖..."
go mod download

echo "请编辑 conf.toml 文件。完成编辑后，按任意键继续..."
sed -i "s/email = \"xxx@gmail.com\"/email = \"$new_email\"/" conf.toml
sed -i "s/password = \"xxx\"/password = \"$new_pwd\"/" conf.toml

echo '国外机器修改main文件'
sed -i.bak 's/client := resty.New\(\).SetProxy\(proxyURL\)./client := resty.New().\n\tSetTLSClientConfig(&tls.Config{InsecureSkipVerify: true}).\n\tSetHeader("content-type", "application/json").\n\tSetHeader("origin", "chrome-extension://fpdkjdnhkakefebpekbdhillbhonfjjp").\n\tSetHeader("accept", "*/*").\n\tSetHeader("accept-language", "en-US,en;q=0.9").\n\tSetHeader("priority", "u=1, i").\n\tSetHeader("sec-fetch-dest", "empty").\n\tSetHeader("sec-fetch-mode", "cors").\n\tSetHeader("sec-fetch-site", "cross-site").\n\tSetHeader("user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36")\nif proxyURL!= "" {\n\tclient.SetProxy(proxyURL)\n}/' main.go

echo "构建项目..."
go build -o main

if [ ! -f "main" ]; then
    echo "构建失败，未找到可执行文件 main。"
    exit 1
fi

echo "执行项目..."
./main

# 执行完成后直接返回主菜单，无需等待用户输入
