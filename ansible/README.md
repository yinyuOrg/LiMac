# Ansible Setup

此目录包含用于在 Debian 13 上配置系统级开发环境的 Ansible 剧本。

## 安装内容

- Docker
- Google Chrome
- 飞书（Feishu）
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

## 注意事项

- 安装飞书和微信前，请先到官网获取最新 `.deb` 下载地址，并更新 `ansible/vars/default.yml` 中的：
  - `feishu_deb_url`
  - `wechat_deb_url`
- 微信官方 Linux 版可能依赖特定库， playbook 最后会自动运行 `apt --fix-broken` 修复。
- Docker 安装后需要重新登录或执行 `newgrp docker` 才能免 sudo 使用。
- 仅 Linux 支持，macOS 上 Ansible playbook 中的部分功能不可用。
