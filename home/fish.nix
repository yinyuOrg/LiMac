{
  pkgs,
  lib,
  ...
}:
{
  programs.fish = {
    enable = true;
    shellInit =
      lib.optionalString pkgs.stdenv.isDarwin ''
        fish_add_path -g $HOME/.nix-profile/bin
        fish_add_path -g /nix/var/nix/profiles/default/bin
        fish_add_path -g /opt/homebrew/bin
      ''
      + lib.optionalString (builtins.pathExists "/opt/homebrew/opt/llvm@19") ''
        fish_add_path /opt/homebrew/opt/llvm@19/bin
        set -gx CC /opt/homebrew/opt/llvm@19/bin/clang
        set -gx CXX /opt/homebrew/opt/llvm@19/bin/clang++
        set -gx LDFLAGS "-L/opt/homebrew/opt/llvm@19/lib"
        set -gx CPPFLAGS "-I/opt/homebrew/opt/llvm@19/include"
      '';
    shellAliases = {
      rm = "trash";
    };
    shellAbbrs = lib.mkMerge [
      {
        g = "git";
        n = "nvim";
        cdtmp = "cd (mktemp -d /tmp/jinser-XXXXXX)";
        decolorize = "sed -r \"s/\\x1B\\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g\"";
        nf = "nix flake";
        ns = "nix shell";
        eproxy = "set -e {HTTP, HTTPS, ALL, FTP, RSYNC}_PROXY";
        bh = "bat --plain --language=help";
        hl = "bat -pp -l";
        fgfg = "fg";
        da = "direnv allow";
      }
      (lib.mkIf pkgs.stdenv.isLinux {
        sc = "systemctl";
        jc = "journalctl";
      })
    ];
    functions = {
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
