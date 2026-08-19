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
│   └── OPERATIONS.md       # 本手册
├── bin/                   # 辅助脚本
│   ├── home-manager-setup # 首次初始化脚本（自动生成属于您的 host 配置文件并应用）
│   ├── update-flake       # 更新 flake.lock
│   └── install-via-ansible # 运行 Ansible playbook
├── flakeModules/          # Flake 模块
│   ├── default.nix
│   ├── formatter.nix      # 格式化配置
│   └── home-manager.nix   # Home Manager 配置输出注册
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
│   │   └── containers.nix
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
nix run nixpkgs#hello
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
如果测试运行 `hello` 仍然无法通过，可安装 systemd 设置套件：
```sh
sudo apt install nix-setup-systemd
```

#### 4. 带有代理的环境测试
```sh
env HTTPS_PROXY=http://127.0.0.1:7890 nix run nixpkgs#hello
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

### 3.4 WSL2 设置 Fish 为默认 Shell

推荐通过修改 Linux 登录 shell 的方式，让 Fish 成为 WSL2 的默认环境。

1. 确认 Fish 已由 Home Manager 安装：
   ```sh
   ls -la ~/.nix-profile/bin/fish
   ```

2. 将 Fish 加入系统允许的 shell 列表，并设为默认登录 shell：
   ```sh
   sudo sh -c "echo $(realpath ~/.nix-profile/bin/fish) >> /etc/shells"
   chsh -s ~/.nix-profile/bin/fish
   ```

3. 退出 WSL 并重启实例使变更生效：
   ```sh
   exit
   ```
   然后在 Windows PowerShell / CMD 中执行：
   ```powershell
   wsl --shutdown
   ```
   重新打开 WSL 后默认即为 Fish。

> **恢复方法**：若设置后无法登录，可在 Windows 终端执行 `wsl -e bash` 进入 Bash，然后运行 `chsh -s /bin/bash` 恢复。

---

## 4. 首次设置与日常应用

克隆此仓库后，在仓库根目录直接运行：

```sh
bin/home-manager-setup
```

脚本会交互式引导你完成：
1. 检查依赖（Nix、Git、Nix daemon 连通性）并开启 Nix Flakes 实验性特性。
2. 自动获取当前系统的用户名、平台与架构。
3. 提示输入 Git 全局的用户名和邮箱。
4. 自选启用的 profile（清单来自 `home/packages.nix` 的 `profileMeta`，默认全部不启用），并在 `~/.config/limac/host.nix` 生成你的本地专属配置文件。
5. **使用 `--impure` 应用**：flake 通过 `--impure` 读取仓库外的本地配置，无需也不会把个人信息提交进仓库。
6. 自动直接应用当前主仓库的配置。

> 重复运行脚本时：已有 `host.nix` 会展示当前启用的 profile 并询问是否重新选择（默认保持）；旧配置缺少 profiles 块时会引导自选补齐。

非交互模式（适合脚本化/自动化装机）：

```sh
bin/home-manager-setup --profiles core,python --git-name "你的名字" --git-email you@example.com
```

完整参数见 `bin/home-manager-setup --help`。`--git-name/--git-email` 仅在首次生成 `host.nix` 时生效；重复运行时带 `--profiles` 会按需更新（与现有一致则幂等跳过）。

---

## 5. 日常应用配置

### 5.1 重新应用 Home Manager

若在 `home/` 目录下修改了软件配置（如增删包、改 fish alias），直接运行以下命令应用（将 `x86_64-linux` / `aarch64-darwin` 等替换为你的实际系统）：

```sh
# Linux x86_64
nix run "nixpkgs#home-manager" -- switch --flake .#x86_64-linux --impure

# Linux aarch64
nix run "nixpkgs#home-manager" -- switch --flake .#aarch64-linux --impure

# macOS Apple Silicon
nix run "nixpkgs#home-manager" -- switch --flake .#aarch64-darwin --impure

# macOS Intel
nix run "nixpkgs#home-manager" -- switch --flake .#x86_64-darwin --impure
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
- VSCode
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
  config,
  lib,
  ...
}:
lib.mkIf config.profiles.python.enable {
  home.packages = with pkgs; [
    (python3.withPackages (ps: [ ps.openpyxl ]))
    uv
    ruff
    poetry # 新增
  ];
}
```

如果新增领域没有对应文件，新建一个 `home/profiles/<name>.nix`，并在 `home/packages.nix` 的 `profileMeta` 中添加一项：

```nix
profileMeta = {
  ai = "AI 相关工具";
  # ...
  my-new-profile = "XXX 工具描述";
};
```

`imports` 与开关选项 `profiles.<name>.enable` 会由 `profileMeta` 自动生成，无需手动维护导入列表；`bin/home-manager-setup` 的交互清单也从这里自动解析（唯一数据源），无需同步修改脚本。

### 7.2 关闭某个领域

在 `~/.config/limac/host.nix` 中设置：

```nix
{
  profiles.<name>.enable = false;
}
```

然后重新应用（`home-manager switch --flake .#<system> --impure`）即可。

### 7.3 系统级 GUI 软件

Chrome、VSCode、微信等通过 Ansible 安装。修改 `ansible/vars/default.yml` 或 `ansible/playbook.yml`。

---

## 8. 添加新 Host / 新用户

由于个人配置已外置到 `~/.config/limac/host.nix`，多用户或新设备的添加已极其简化：

1. **在新设备/新用户环境下**，直接运行初始化脚本：
   ```sh
   bin/home-manager-setup
   ```
2. 脚本会自动为你生成正确的 `~/.config/limac/host.nix` 配置文件。
3. `flakeModules/home-manager.nix` 已提供固定的系统级输出（`x86_64-linux`、`aarch64-linux`、`x86_64-darwin`、`aarch64-darwin`），脚本会自动选择对应输出并带 `--impure` 应用，无需手动修改任何 Nix 代码。

---

## 9. 更新微信下载地址

微信的 `.deb` 下载地址可能会更新。请定期维护 `ansible/vars/default.yml` 中的 `wechat_deb_urls`。

### 9.1 获取微信地址

微信地址通常比较稳定，按架构分别维护：

```yaml
wechat_deb_urls:
  x86_64: "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"
  aarch64: "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_arm64.deb"
```

Playbook 会根据当前机器架构自动选择对应的下载地址；未列出的架构会自动跳过微信安装。

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

### 11.1 Nix 提示找不到本地 host 文件

本项目把个人配置放在仓库外的 `~/.config/limac/host.nix`。请确认：

1. 该文件已存在（可重新运行 `bin/home-manager-setup` 生成）。
2. 所有 `home-manager switch` 命令都带有 `--impure`，否则 Nix 不会读取仓库外的文件。

示例：
```sh
nix run "nixpkgs#home-manager" -- switch --flake .#x86_64-linux --impure
```

### 11.2 运行 `nix fmt` 报错 `does not provide attribute 'formatter...'`

确保 `flake.nix` 中的 `systems` 包含当前机器架构。例如 macOS Apple Silicon 需要 `aarch64-darwin`。

### 11.3 Docker 安装后仍需要 sudo

运行：

```sh
newgrp docker
```

或重新登录。

### 11.4 微信安装后缺少依赖

Ansible 最后会自动运行 `apt --fix-broken install`。如果仍失败，可以手动运行：

```sh
sudo apt --fix-broken install
```
