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
    ./profiles/ide.nix
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "vscode"
    ];
}
