{
  pkgs,
  lib,
  ...
}:
{
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  targets.genericLinux.enable = lib.mkIf pkgs.stdenv.isLinux true;
}
