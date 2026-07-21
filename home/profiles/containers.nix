{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.profiles.containers.enable {
  home.packages = with pkgs; [
    docker-compose
    kubectl
  ];
}
