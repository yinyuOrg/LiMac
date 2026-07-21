{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.profiles.cpp.enable {
  home.packages = with pkgs; [
    gcc
    cmake
    ninja
  ];
}
