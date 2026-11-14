{ config, lib, pkgs, inputs, ... }:
let
  vintagestoryPackages = inputs.vintagestory-nix.packages.${pkgs.stdenv.hostPlatform.system};
  cfg = config.gaming.vintagestory;
in
{
  options.gaming.vintagestory.enable = lib.mkEnableOption "Vintage Story";

  config = lib.mkIf cfg.enable {
    # Allow insecure dotnet runtime so that Vintage Story will work
    nixpkgs.config.permittedInsecurePackages = [
      "dotnet-runtime-wrapped-7.0.20"
      "dotnet-runtime-7.0.20"
    ];

    # Set overlay for vintage story package
    nixpkgs.overlays = [inputs.vintagestory-nix.overlays.default];
    environment.systemPackages = [
      vintagestoryPackages.latest # ignores RCs
      vintagestoryPackages.rustique
      vintagestoryPackages.vs-launcher
    ];
  };
}
