{
  lib,
  ...
}:
let
  # 单一来源：新增 profile 时只需在此添加一项；
  # 同时驱动 imports 与 options.profiles.<name>.enable
  profileMeta = {
    ai = "启用 AI 相关工具";
    core = "启用核心基础工具";
    python = "启用 Python 开发套件";
    java = "启用 Java 开发套件";
    cpp = "启用 C++ 开发套件";
    embedded = "启用嵌入式开发套件";
    containers = "启用容器/K8s工具";
  };
  profileNames = builtins.attrNames profileMeta;
in
{
  imports = map (name: ./profiles/${name}.nix) profileNames;

  options.profiles = lib.genAttrs profileNames (name: {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = profileMeta.${name};
    };
  });
}
