{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    gcc-arm-embedded
    openocd
    stlink
    esptool
    picotool
    minicom
  ];
}
