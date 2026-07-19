# LiMac/home 操作手册

本文档记录本项目的日常操作、高级安装配置、终端 Shell 设置以及疑难解答。

---

## 1. 项目结构

```
.
├── flake.nix              # Flake 入口
├── flake.lock             # 依赖锁定
├── README.md              # 快速开始
├── docs/
│   └── operations.md       # 本手册
├── bin/                   # 辅助脚本
│   ├── home-manager-setup # 首次初始化脚本（自动生成属于您的 host 配置文件并应用）
│   ├── update-flake       # 更新 flake.lock
│   └── install-via-ansible # 运行 Ansible playbook
├── flakeModules/          # Flake 模块
│   ├── default.nix
│   ├── formatter.nix      # 格式化配置
│   └── home-manager.nix   # Home Manager 动态扫描与配置自动注册
├── home/                  # Home Manager 模块（用户环境）
│   ├── default.nix        # 聚合入口
│   ├── common.nix         # 基础配置
│   ├── fish.nix           # Fish Shell
│   ├── git.nix            # Git 配置
│   ├── packages.nix       # 软件包聚合
│   ├── profiles/          # 按领域拆分的软件包
│   │   ├── ai.nix
│   │   ├── core.nix
│   │   ├── python.nix
│   │   ├── java.nix
│   │   ├── cpp.nix
│   │   ├── embedded.nix
│   │   ├── containers.nix
│   │   └── ide.nix
│   └── platforms/         # 平台特定配置
│       ├── linux.nix
│       └── darwin.nix
├── hosts/                 # 用户特定本地配置文件目录（动态发现，不提交到主仓库）
│   └── .gitkeep           # 保持 hosts 目录存在
└── ansible/               # 系统级安装（仅 Debian/Ubuntu）
    ├── playbook.yml
    ├── inventory.ini
    ├── ansible.cfg
    └── vars/
        └── default.yml
```

---

## 2. 高级 Nix 安装与配置指导

在运行初始化之前，你需要确保 Nix 包管理器已正确安装。

### 2.1 macOS 安装

直接使用官方守护进程安装：
```sh
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

### 2.2 Linux (Debian 13) 基础安装（推荐：终端已可翻墙）

如果你的终端已经可以直接翻墙，只需执行以下极简步骤：

#### Step 1: 安装 Nix
```sh
sudo apt install nix
```

#### Step 2: 配置 trusted-users（Flakes 必须）
编辑 `/etc/nix/nix.conf`（可以使用 sudo 权限），填入以下基础配置。
**注意：** 必须将 `trusted-users` 中的 `your_username` 修改为您当前系统的用户名（可通过 `whoami` 查看）：
```ini
sandbox = true
experimental-features = nix-command flakes 
trusted-users = root your_username
build-users-group = nixbld
```

#### Step 3: 将用户加入 nix-users 组并重启
```sh
sudo usermod -aG nix-users $(whoami)
```
**注意：执行此操作后，请重新启动电脑以使组变更生效。**

#### Step 4: 联通性测试
重启电脑后，直接运行以下命令测试：
```sh
nix run --refresh git+https://gitee.com/XmacsLabs/goldfish?ref=main
```

---

### 💡 可选：如果您的终端无法直接翻墙（手动配置国内源与代理）

如果你的终端网络受限、无法直接访问外部网络，可参考本节配置国内镜像源以及手动代理。

#### 1. 配置清华 TUNA 镜像源
编辑 `/etc/nix/nix.conf`，将配置修改为：
```ini
sandbox = true

substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store  https://cache.nixos.org/  
trusted-substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store  https://cache.nixos.org/  
trusted-users = root your_username  

experimental-features = nix-command flakes 

build-users-group = nixbld
```

#### 2. 为 nix-daemon 守护进程手动配置代理 (默认 7890 端口)
由于 Nix 绝大多数包由 `nix-daemon` 独立下载，需要编辑守护进程配置来应用代理：
```sh
sudo systemctl edit --runtime nix-daemon
```
在编辑器中填入以下配置：
```ini
[Service]
Environment="ALL_PROXY=http://127.0.0.1:7890"
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
```

#### 3. 常见 Socket 异常修复
如果遇到 Nix 守护进程异常，可尝试清理异常套接字并重启：
```sh
sudo rm -rf /nix/var/nix/daemon-socket/socket
sudo systemctl restart nix-daemon
```
如果测试运行 `goldfish` 仍然无法通过，可安装 systemd 设置套件：
```sh
sudo apt install nix-setup-systemd
```

#### 4. 带有代理的环境测试
```sh
env HTTPS_PROXY=http://127.0.0.1:7890 nix run --refresh git+https://gitee.com/XmacsLabs/goldfish?ref=main
```

---

## 3. 终端 Shell 设置指导

应用 Home Manager 成功后，若要使系统级 Fish 成为你的主环境，请参考以下设置。

### 3.1 Linux (KDE Konsole) 设置步骤
1. 打开 Konsole，点击右上角三横杠菜单，选择 `Create New Profile...`
2. 设置名称为 `LiMac`。
3. 勾选设为默认配置文件 `Default profile`。
4. 将 `Command` 输入框更新为：
   ```sh
   /home/<YOUR_USERNAME>/.nix-profile/bin/fish
   ```
   *(请将 `<YOUR_USERNAME>` 替换为实际用户名)*

### 3.2 macOS (iTerm2 / Terminal) 设置步骤
1. 打开 iTerm2 / Terminal。
2. 进入 Preferences/Settings -> Profiles -> General -> Command。
3. 选择 `Command`（而不是 Login Shell），填入：
   ```sh
   /Users/<YOUR_USERNAME>/.nix-profile/bin/fish
   ```
   *(请将 `<YOUR_USERNAME>` 替换为实际用户名)*

### 3.3 VS Code 终端 Fish 默认设置
1. 在 VS Code 中打开全局设置 (`Ctrl+,` 或 `Cmd+,`)。
2. 搜索 `terminal.integrated.defaultProfile.osx` 并设为 `"fish"`。
3. 搜索或编辑 `settings.json`，确保包含以下配置（以 macOS 为例）：
   ```json
   "terminal.integrated.profiles.osx": {
     "fish": {
       "path": "/Users/<YOUR_USERNAME>/.nix-profile/bin/fish",
       "args": []
     }
   },
   "terminal.integrated.defaultProfile.osx": "fish"
   ```

---

## 4. 首次设置与日常应用

克隆此仓库后，在仓库根目录直接运行：

```sh
bin/home-manager-setup
```

脚本会交互式引导你完成：
1. 检查并开启 Nix Flakes 实验性特性。
2. 自动获取当前系统的用户名和平台。
3. 提示输入 Git 全局的用户名和邮箱。
4. 自动在 `hosts/` 目录下生成专属配置文件：
   - Linux: `hosts/<username>.linux.nix`
   - macOS: `hosts/<username>.darwin.nix`
5. **重要**：因为 Nix Flakes 只读取被 Git 跟踪的文件，脚本会暂停并等待你在另一个窗口执行 `git add hosts/<username>.<platform>.nix`。
6. 暂存后，输入 `y` 继续，脚本将直接应用当前主仓库的配置。

---

## 5. 日常应用配置

### 5.1 重新应用 Home Manager

若在 `home/` 目录下修改了软件配置（如增删包、改 fish alias），直接运行以下命令应用（将 `<username>` 替换为你的当前用户名）：

```sh
# Linux
nix run "nixpkgs#home-manager" -- switch --flake .#<username>.linux

# macOS (Apple Silicon)
nix run "nixpkgs#home-manager" -- switch --flake .#<username>.darwin
```

### 5.2 应用 Ansible 系统级配置 (仅 Linux)

```sh
bin/install-via-ansible
```

等效于：

```sh
ansible-playbook ansible/playbook.yml -i ansible/inventory.ini --ask-become-pass
```

Ansible 会安装：
- Docker
- Google Chrome
- 飞书（Feishu）
- 微信（WeChat）

---

## 6. 更新依赖

### 6.1 更新 flake.lock

```sh
bin/update-flake
```

或者手动：

```sh
nix flake update
```

### 6.2 格式化所有 Nix 文件

```sh
nix fmt
```

---

## 7. 修改软件包

### 7.1 添加/删除用户级软件包

编辑 `home/profiles/<领域>.nix`，在对应的 `home.packages` 列表中增删即可。

例如添加 Python 工具：

```nix
# home/profiles/python.nix
{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    python3
    uv
    ruff
    poetry    # 新增
  ];
}
```

如果新增 of 领域没有对应文件，可以新建一个 `home/profiles/<name>.nix`，并在 `home/packages.nix` 中导入：

```nix
imports = [
  ./profiles/ai.nix
  ./profiles/core.nix
  ./profiles/python.nix
  # ...
  ./profiles/my-new-profile.nix
];
```

### 7.2 关闭某个领域

直接注释掉 `home/packages.nix` 中对应的 `imports` 行即可。

### 7.3 系统级 GUI 软件

Chrome、飞书、微信等通过 Ansible 安装。修改 `ansible/vars/default.yml` 或 `ansible/playbook.yml`。

---

## 8. 添加新 Host / 新用户

由于本项目已完全迁移为**纯动态生成**机制，多用户或新设备的添加已极其简化：

1. **在新设备/新用户环境下**，直接运行初始化脚本：
   ```sh
   bin/home-manager-setup
   ```
2. 脚本会自动为你生成正确的 `hosts/<username>.<platform>.nix` 配置文件。
3. 执行 `git add` 并按下 `y` 确认，`flakeModules/home-manager.nix` 会**自动发现并注册**你的新配置名，无需手动修改任何 Nix 代码。

---

## 9. 更新飞书/微信下载地址

飞书和微信的 `.deb` 下载地址会更新。请定期维护 `ansible/vars/default.yml`。

### 9.1 获取飞书地址

1. 打开 https://www.feishu.cn/download
2. 选择 Linux 桌面客户端
3. 点击下载，从浏览器下载记录或开发者工具中复制 `.deb` 直链
4. 更新 `ansible/vars/default.yml` 中的 `feishu_deb_url`

### 9.2 获取微信地址

微信地址通常比较稳定：

```yaml
wechat_deb_url: "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"
```

如需 ARM 版本，替换为：

```yaml
wechat_deb_url: "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_arm64.deb"
```

---

## 10. 验证与检查

| 目的 | 命令 |
|---|---|
| 检查 Nix flake 结构与语法 | `nix flake check --no-build` |
| 查看注册的所有配置名 | `nix flake show` |
| 格式化 Nix 文件 | `nix fmt` |
| 检查 Ansible 语法 | `ansible-playbook --syntax-check ansible/playbook.yml -i ansible/inventory.ini` |
| 查看 Home Manager 新闻 | `home-manager news` |

---

## 11. 常见问题

### 11.1 Nix 提示找不到新生成的 host 文件

这是由于 Nix Flakes 只读取已加入 Git 跟踪的文件。请确保已在终端执行：
```sh
git add hosts/<username>.<platform>.nix
```

### 11.2 运行 `nix fmt` 报错 `does not provide attribute 'formatter...'`

确保 `flake.nix` 中的 `systems` 包含当前机器架构。例如 macOS Apple Silicon 需要 `aarch64-darwin`。

### 11.3 Ansible 提示飞书 URL 未更新

这是预期行为。请按 [第 9 节](#9-更新飞书微信下载地址) 更新 `ansible/vars/default.yml` 中的 `feishu_deb_url`。

### 11.4 Docker 安装后仍需要 sudo

运行：

```sh
newgrp docker
```

或重新登录。

### 11.5 微信安装后缺少依赖

Ansible 最后会自动运行 `apt --fix-broken install`。如果仍失败，可以手动运行：

```sh
sudo apt --fix-broken install
```
