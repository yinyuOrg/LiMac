{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.profiles.embedded.enable {
  home.packages = with pkgs; [
    gcc-arm-embedded
    openocd
    stlink
    esptool
    picotool
    minicom
  ];
}
