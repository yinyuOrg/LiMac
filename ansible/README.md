# Ansible Setup

此目录包含用于在 Debian 13 上配置系统级开发环境的 Ansible 剧本。

## 安装内容

- Docker
- Google Chrome
- VSCode
- 微信（WeChat）

## 前置要求

- 系统已安装 Ansible
- 已安装 Python 3
- 具有软件包安装的 sudo 权限

## 使用方法

从项目根目录运行：

```bash
bin/install-via-ansible
```

或手动：

```bash
ansible-playbook ansible/playbook.yml -i ansible/inventory.ini --ask-become-pass
```

---

## 如何卸载

### 全部卸载

```bash
sudo apt remove --purge \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  google-chrome-stable code com.tencent.wechat
sudo rm -f /etc/apt/sources.list.d/{docker,google-chrome,vscode}.sources
sudo rm -f /usr/share/keyrings/{docker,google-chrome,microsoft}.asc
sudo apt update
```

> 微信包名可能不同，可用 `dpkg -l | grep -i wechat` 查看后替换。

### 单独卸载

```bash
# Docker
sudo apt remove --purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo rm -f /etc/apt/sources.list.d/docker.sources /usr/share/keyrings/docker.asc

# Google Chrome
sudo apt remove --purge google-chrome-stable
sudo rm -f /etc/apt/sources.list.d/google-chrome.sources /usr/share/keyrings/google-chrome.asc

# VSCode
sudo apt remove --purge code
sudo rm -f /etc/apt/sources.list.d/vscode.sources /usr/share/keyrings/microsoft.asc

# 微信
sudo dpkg -l | grep -i wechat
sudo apt remove --purge <实际包名>
```

---

## 注意事项

- 安装微信前，请先到官网获取最新 `.deb` 下载地址，并更新 `ansible/vars/default.yml` 中的 `wechat_deb_urls`（按 `x86_64` / `aarch64` 架构分别维护）。
- 微信官方 Linux 版可能依赖特定库， playbook 最后会自动运行 `apt --fix-broken` 修复。
- Docker 安装后需要重新登录或执行 `newgrp docker` 才能免 sudo 使用。
- 仅 Linux 支持，macOS 上 Ansible playbook 中的部分功能不可用。
