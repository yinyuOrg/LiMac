{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.profiles.ai.enable {
  home.packages = with pkgs; [
    claude-code
    opencode
    codex
  ];
}
