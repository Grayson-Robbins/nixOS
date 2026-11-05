{ config, lib, pkgs, inputs, ... }:
let
  vintagestoryPackages = inputs.vintagestory-nix.packages.${pkgs.stdenv.hostPlatform.system};
  cfg = config.gaming.vintagestory;
in
{
  options.gaming.vintagestory.enable = lib.mkEnableOption "Vintage Story";

  config = lib.mkIf cfg.enable {
    # Set overlay for vintage story package
    nixpkgs.overlays = [inputs.vintagestory-nix.overlays.default];
    environment.systemPackages = [
      vintagestoryPackages.latest # ignores RCs
      vintagestoryPackages.rustique
      vintagestoryPackages.vs-launcher
    ];
  };
}
