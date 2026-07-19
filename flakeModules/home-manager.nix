{
  inputs,
  lib,
  ...
}:
let
  hostsDir = ../hosts;
  hostFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name) (
    builtins.readDir hostsDir
  );

  # Parse a filename like "alice.linux.nix" into:
  #   username = "alice"; platform = "linux"; system = "x86_64-linux"
  parseHostFile =
    name:
    let
      base = lib.removeSuffix ".nix" name;
      parts = lib.splitString "." base;
      hasPlatform = builtins.length parts > 1;
      platform = if hasPlatform then lib.last parts else "linux";
      username = if hasPlatform then lib.concatStringsSep "." (lib.init parts) else base;
      system =
        {
          linux = "x86_64-linux";
          darwin = "aarch64-darwin";
          aarch64-linux = "aarch64-linux";
          x86_64-darwin = "x86_64-darwin";
        }
        .${platform} or "x86_64-linux";
    in
    {
      inherit username system;
      configName = base;
      path = hostsDir + "/${name}";
    };

  homeModules.default =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Sensible default for `home.homeDirectory`
      home.homeDirectory = lib.mkDefault "/${
        if pkgs.stdenv.isDarwin then "Users" else "home"
      }/${config.home.username}";

      imports = [ ../home ];
    };

  mkHomeConfig =
    name: _:
    let
      info = parseHostFile name;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${info.system};
      modules = [
        homeModules.default
        info.path
      ];
    };
in
{
  flake = {
    inherit homeModules;
    homeConfigurations = lib.mapAttrs' (
      name: value: lib.nameValuePair (parseHostFile name).configName (mkHomeConfig name value)
    ) hostFiles;
  };
}
