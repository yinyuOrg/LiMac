{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.profiles.ide.enable {
  home.packages = with pkgs; [
    vscode
  ];
}
