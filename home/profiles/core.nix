{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.profiles.core.enable {
  home.packages =
    with pkgs;
    lib.mkMerge [
      [
        ansible
        curl
        ripgrep
        bat
        fd
        tig
        direnv
        tree
        nix-output-monitor
        trash-cli
      ]

      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
        ossutil
        awscli2
        tlrc
      ])
    ];
}
