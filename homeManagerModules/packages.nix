{ config, lib, pkgs, inputs, ... }: 

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-7.0.20"
  ];
  home.packages = with pkgs; [
    qutebrowser
    discord
    nerd-fonts.iosevka
    vintagestory
    ollama
    lagrange
    copyq
    pavucontrol
    bottom
    orpie
    dolphin
    gthumb
    wl-clipboard
    gitui
  ];
}

