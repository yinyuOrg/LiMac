{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.fish = {
    enable = true;
    shellInit =
      lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        fish_add_path -g $HOME/.nix-profile/bin
        fish_add_path -g /nix/var/nix/profiles/default/bin
        fish_add_path -g /opt/homebrew/bin
      ''
      + lib.optionalString (builtins.pathExists "/opt/homebrew/opt/llvm") ''
        fish_add_path /opt/homebrew/opt/llvm/bin
        set -gx CC /opt/homebrew/opt/llvm/bin/clang
        set -gx CXX /opt/homebrew/opt/llvm/bin/clang++
        set -gx LDFLAGS "-L/opt/homebrew/opt/llvm/lib"
        set -gx CPPFLAGS "-I/opt/homebrew/opt/llvm/include"
      '';
    shellAliases = lib.mkIf config.profiles.core.enable {
      rm = "trash";
    };
    shellAbbrs = lib.mkMerge [
      {
        g = "git";
        n = "nvim";
        cdtmp = "cd (mktemp -d /tmp/limac-XXXXXX)";
        nf = "nix flake";
        ns = "nix shell";
        eproxy = "set -e {HTTP, HTTPS, ALL, FTP, RSYNC}_PROXY";
        bh = "bat --plain --language=help";
        hl = "bat -pp -l";
        fgfg = "fg";
        da = "direnv allow";
      }
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        sc = "systemctl";
        jc = "journalctl";
      })
    ];
    functions = {
      decolorize = {
        description = "Strip ANSI color/escape codes from input";
        # fish <= 4.8 中函数内 string 读不到管道 stdin（fish-shell#5714），需经 cat 中转
        body = "cat $argv | string replace -ra '\\x1B\\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]' ''";
      };
      cht = {
        description = "Check the cheat sheet for command";
        body =
          # fish
          ''
            curl -s "https://cht.sh/$argv"
            printf '\n'
          '';
      };
      nr = {
        description = "Shortcut for run package from nixpkgs";
        body =
          # fish
          ''
            nix run "nixpkgs#$argv[1]" $argv[2..]
          '';
      };
    };
  };
}
