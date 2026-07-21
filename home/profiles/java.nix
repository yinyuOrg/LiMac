{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.profiles.java.enable {
  home.packages = with pkgs; [
    jdk21
    maven
  ];
}
