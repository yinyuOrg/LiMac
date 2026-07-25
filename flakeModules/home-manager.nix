{
  inputs,
  lib,
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
        ../home/platforms/linux.nix
        ../home/platforms/darwin.nix
      ];
    };

  # When running with --impure, the per-machine config living outside the repo
  # is imported here. In pure mode HOME is empty, so it is skipped.
  userHome = builtins.getEnv "HOME";
  localHostFile = "${userHome}/.config/limac/host.nix";
  hasLocalHost = userHome != "" && builtins.pathExists localHostFile;

  mkHomeConfig =
    name: system:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [
        homeModules.default
      ] ++ lib.optional hasLocalHost localHostFile;
    };

  platforms = {
    x86_64-linux = "x86_64-linux";
    aarch64-linux = "aarch64-linux";
    x86_64-darwin = "x86_64-darwin";
    aarch64-darwin = "aarch64-darwin";
  };
in
{
  flake = {
    inherit homeModules;
    homeConfigurations = lib.mapAttrs' (
      name: system: lib.nameValuePair name (mkHomeConfig name system)
    ) platforms;
  };
}
