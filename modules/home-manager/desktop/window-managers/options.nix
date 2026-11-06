{ lib, ... }:
{
  options.my.home.windowManagers = {
    hyprland.enable = lib.mkEnableOption "Hyprland";
    niri.enable = lib.mkEnableOption "Niri";
  };
}
