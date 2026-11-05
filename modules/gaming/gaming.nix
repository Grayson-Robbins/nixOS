{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.gaming;
in
{
  imports = [
    ./steam.nix
    ./vr.nix
    ./vintagestory.nix
  ];

  options.gaming = {
    enable = lib.mkEnableOption "Gaming";
  };

  config = lib.mkIf cfg.enable {
    steam.enable = lib.mkDefault true;
    vr.enable = lib.mkDefault true;
    vintagestory.enable = lib.mkDefault true;
  };
}
