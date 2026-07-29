{
  inputs,
  lib,
  config,
  ...
}:
let
  homeModules.default =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Provide a fallback username so that pure evaluation (e.g. nix flake check)
      # succeeds even when the per-machine config is not available.
      home.username = lib.mkDefault "limac";

      home.homeDirectory = lib.mkDefault "/${
        if pkgs.stdenv.isDarwin then "Users" else "home"
      }/${config.home.username}";

      imports = [
        ../home
      ];
    };

  # When running with --impure, the per-machine config living outside the repo
  # is imported here. In pure mode HOME is empty, so it is skipped.
  userHome = builtins.getEnv "HOME";
  localHostFile = "${userHome}/.config/limac/host.nix";
  hasLocalHost = userHome != "" && builtins.pathExists localHostFile;

  mkHomeConfig =
    _name: system:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [
        homeModules.default
      ]
      ++ lib.optional hasLocalHost localHostFile;
    };

  # platforms 来自 flake-parts 在 flake.nix 中声明的 systems，
  # 这里直接派生以避免列表重复维护
  platforms = lib.genAttrs config.systems (name: name);
in
{
  flake = {
    inherit homeModules;
    homeConfigurations = lib.mapAttrs' (
      name: system: lib.nameValuePair name (mkHomeConfig name system)
    ) platforms;
  };
}
