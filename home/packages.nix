{
  lib,
  ...
}:
{
  imports = [
    ./profiles/ai.nix
    ./profiles/core.nix
    ./profiles/python.nix
    ./profiles/java.nix
    ./profiles/cpp.nix
    ./profiles/embedded.nix
    ./profiles/containers.nix
  ];

  options.profiles = {
    ai.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "启用 AI 相关工具";
    };
    core.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "启用核心基础工具";
    };
    python.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "启用 Python 开发套件";
    };
    java.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "启用 Java 开发套件";
    };
    cpp.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "启用 C++ 开发套件";
    };
    embedded.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "启用嵌入式开发套件";
    };
    containers.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "启用容器/K8s工具";
    };
  };

  config.nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];
}
