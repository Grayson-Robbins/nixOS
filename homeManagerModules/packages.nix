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
    bottom
    orpie
    gthumb
    wl-clipboard
    gitui
  ];
}

