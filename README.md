# Home Managed by LiMac

跨平台用户开发环境统一配置，基于 **Nix Flakes** 与 **Home Manager**。

---

## 🚀 3分钟快速开始

### 第一步：安装 Nix

#### Linux (Debian / Ubuntu)

1. 安装 Nix 包：
    ```sh
    sudo apt install nix
    ```

2. 编辑 `/etc/nix/nix.conf`，写入基础配置（**将 `your_username` 替换为你的实际用户名**，可通过 `whoami` 查看）：
    ```ini
    sandbox = true
    experimental-features = nix-command flakes
    trusted-users = root your_username
    build-users-group = nixbld
    ```

3. 将当前用户加入 `nix-users` 组，然后**重启电脑**使组变更生效：
    ```sh
    sudo usermod -aG nix-users $(whoami)
    ```

    > 重启后可通过 `id` 命令确认输出中包含 `nix-users`。若临时想在不重启的情况下继续，可在当前终端执行 `newgrp nix-users`。

*(若遇网络问题或需要设置代理，请参阅 [高级 Nix 安装与配置指导](docs/OPERATIONS.md#2-高级-nix-安装与配置指导))*

#### macOS (Apple Silicon)

```sh
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

### 第二步：配置初始化与应用

全局翻墙后，在克隆好的本仓库根目录下直接运行：

```sh
bin/home-manager-setup
```

1.  **自动生成专属配置文件**：脚本会根据当前系统用户名和平台，在 `hosts/` 目录下创建你的 Host 配置：
    *   Linux: `hosts/<username>.linux.nix`
    *   macOS: `hosts/<username>.darwin.nix`
2.  **自动加入 Git 跟踪**：因为 Nix Flakes 纯评估安全限制，脚本会自动将新生成的配置文件通过 `git add` 暂存，省去手动操作。
3.  **直接应用**：一键自动应用所有用户包与环境配置。

### 第三步：更换默认 Shell

要享受所有 Nix 软件与 Fish 别名，需使用 Home Manager 管理的 Shell。
*   **Fish 路径**：
    *   Linux: `/home/<username>/.nix-profile/bin/fish`
    *   macOS: `/Users/<username>/.nix-profile/bin/fish`

*(具体终端如 Konsole、iTerm2 或 VS Code 终端的切换步骤请参考 [终端 Shell 设置指导](docs/OPERATIONS.md#3-终端-shell-设置指导))*

---

## 🛠️ 系统级安装 (可选，仅 Linux)

安装系统级 GUI 工具（Docker, Chrome, 飞书, 微信），直接运行：

```sh
bin/install-via-ansible
```

---

## 🔄 日常维护

| 目的 | 命令 |
|---|---|
| **格式化配置** | `nix fmt` |
| **升级所有依赖** | `bin/update-flake` |
| **Linux 应用更新** | `nix run "nixpkgs#home-manager" -- switch --flake .#<username>.linux` |
| **macOS 应用更新** | `nix run "nixpkgs#home-manager" -- switch --flake .#<username>.darwin` |

---

## 📖 更多参考

项目结构、高级定制、如何新增软件包或用户，请参考 ➡️ [操作手册 (docs/OPERATIONS.md)](docs/OPERATIONS.md)。
