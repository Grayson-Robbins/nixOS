{ config, lib, pkgs, inputs, ... }: 

{
  #nixpkgs.config.allowUnfree = true;
  #nixpkgs.config.permittedInsecurePackages = [
  #"dotnet-runtime-7.0.20"
  #];
  home.packages = with pkgs; [
    #discord
    nerd-fonts.iosevka
    #vintagestory
    lagrange
    copyq
    orpie
    gthumb
    gitui
  ];
}

