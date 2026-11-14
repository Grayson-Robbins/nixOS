{ lib, ... }:
{
  imports = [
    ./options.nix
    ./hyprland.nix
    ./niri.nix
  ];

  my.home.windowManagers = {
    hyprland.enable = lib.mkDefault false;
    niri.enable = lib.mkDefault true;
  };
}
