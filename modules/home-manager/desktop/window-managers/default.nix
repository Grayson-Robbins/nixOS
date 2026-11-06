{ lib, ... }:
{
  imports = [
    ./options.nix
    ./hyprland.nix
    ./niri.nix
  ];

  my.home.windowManagers = {
    hyprland.enable = lib.mkDefault true;
    niri.enable = lib.mkDefault false;
  };
}
