{
  lib,
  ...
}:
let
  # 单一来源：新增 profile 时只需在此添加一项；
  # 同时驱动 imports 与 options.profiles.<name>.enable
  profileMeta = {
    ai = "AI 相关工具";
    core = "核心基础工具（ansible、ripgrep、bat、fd 等）";
    python = "Python 开发套件";
    java = "Java 开发套件";
    cpp = "C++ 开发套件";
    embedded = "嵌入式开发套件（openocd、stlink 等）";
    containers = "容器/K8s 工具（docker-compose、kubectl）";
  };
  profileNames = builtins.attrNames profileMeta;
in
{
  imports = map (name: ./profiles/${name}.nix) profileNames;

  options.profiles = lib.genAttrs profileNames (name: {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = profileMeta.${name};
    };
  });
}
