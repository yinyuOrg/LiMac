{
  pkgs,
  lib,
  ...
}:
{
  home.packages =
    with pkgs;
    lib.mkMerge [
      [
        ansible
        ripgrep
        bat
        fd
        tig
        direnv
        tree
        nix-output-monitor
        trash-cli
      ]

      (lib.mkIf pkgs.stdenv.isLinux [
        ossutil
        awscli2
        tlrc
      ])
    ];
}
