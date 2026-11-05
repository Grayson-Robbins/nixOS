{ config, lib, ... }:

let
  cfg = config.gaming;
in
{
  imports = [
    ./steam.nix
    ./vr.nix
    ./vintagestory.nix
    ./vintagestory-server.nix
  ];

  options.gaming = {
    enable = lib.mkEnableOption "Gaming";
  };

  config = lib.mkIf cfg.enable {
    gaming = {
      steam.enable = lib.mkDefault true;
      vr.enable = lib.mkDefault true;
      vintagestory.enable = lib.mkDefault true;
      vintagestory-server.enable = lib.mkDefault false;
    };
  };
}
