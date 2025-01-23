# 安装和配置 Teneo 函数
function setup_Teneonode() {
    # 检查 teneo 目录是否存在，如果存在则删除
    if [ -d "teneo" ]; then
        echo "检测到 teneo 目录已存在，正在删除..."
        rm -rf teneo
        echo "teneo 目录已删除。"
    fi

    # 检查并终止已存在的 teneo tmux 会话
    if tmux has-session -t teneo 2>/dev/null; then
        echo "检测到正在运行的 teneo 会话，正在终止..."
        tmux kill-session -t teneo
        echo "已终止现有的 teneo 会话。"
    fi
    
    echo "正在从 GitHub 克隆 teneo 仓库..."
    git clone https://github.com/sdohuajia/Teneo.git teneo
    if [ ! -d "teneo" ]; then
        echo "克隆失败，请检查网络连接或仓库地址。"
        exit 1
    fi

    cd "teneo" || { echo "无法进入 teneo 目录"; exit 1; }

    # 安装 Node.js 和 npm（如果尚未安装）
    if ! command -v npm &> /dev/null; then
    echo "正在安装 Node.js 和 npm..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    fi

    # 安装 npm 依赖项
    echo "正在安装 npm 依赖项..."
    npm install || { echo "npm 依赖项安装失败"; exit 1; }

    # 获取邮箱和密码
    read -p "请输入邮箱: " email
    read -s -p "请输入密码: " password
    echo  # 换行

    # 将邮箱和密码以 "邮箱,密码" 格式保存到 account.txt 文件
    echo "${email},${password}" >> account.txt

    echo "账户信息已保存到 account.txt"

    # 配置代理信息
    read -p "请输入您的代理信息，格式为 http://user:pass@ip:port: " proxy_info
    proxies_file="/root/teneo/proxy.txt"

    # 将代理信息写入文件
    echo "$proxy_info" > "$proxies_file"
    echo "代理信息已添加到 $proxies_file."

    echo "正在使用 tmux 启动应用..."
    tmux new-session -d -s teneo  # 创建新的 tmux 会话，名称为 teneo
    tmux send-keys -t teneo "cd teneo" C-m  # 切换到 teneo 目录
    tmux send-keys -t teneo "node index.js" C-m  # 使用 node index 启动应用
    echo "使用 'tmux attach -t teneo' 命令来查看日志。"
    echo "要退出 tmux 会话，请按 Ctrl+B 然后按 D。"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
}
