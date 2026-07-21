{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.profiles.python.enable {
  home.packages = with pkgs; [
    python3
    uv
    ruff
  ];
}
