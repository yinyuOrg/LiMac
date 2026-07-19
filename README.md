# Home Managed by LiMac

跨平台用户开发环境统一配置，基于 **Nix Flakes** 与 **Home Manager**。

---

## 🚀 3分钟快速开始

### 第一步：安装 Nix

在终端直接运行以下官方一键安装命令：

*   **Linux (Debian / Ubuntu)**:
    ```sh
    sudo apt install nix
    ```
    *(若遇网络问题或需要设置代理，请参阅 [高级 Nix 安装与配置指导](docs/operations.md#2-高级-nix-安装与配置指导))*

*   **macOS (Apple Silicon)**:
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
2.  **加入 Git 跟踪**：因为 Nix Flakes 纯评估安全限制，脚本会暂停并等待你手动将新生成的配置文件暂存：
    ```sh
    git add hosts/<username>.<platform>.nix
    ```
3.  **直接应用**：在脚本中输入 `y` 确认，即可一键应用所有用户包与环境配置。

### 第三步：更换默认 Shell

要享受所有 Nix 软件与 Fish 别名，需使用 Home Manager 管理的 Shell。
*   **Fish 路径**：
    *   Linux: `/home/<username>/.nix-profile/bin/fish`
    *   macOS: `/Users/<username>/.nix-profile/bin/fish`

*(具体终端如 Konsole、iTerm2 或 VS Code 终端的切换步骤请参考 [终端 Shell 设置指导](docs/operations.md#3-终端-shell-设置指导))*

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

项目结构、高级定制、如何新增软件包或用户，请参考 ➡️ [操作手册 (docs/operations.md)](docs/operations.md)。
