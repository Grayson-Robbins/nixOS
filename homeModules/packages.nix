{ pkgs, ... }: 

{
  home.packages = with pkgs; [
    nerd-fonts.iosevka
    lagrange
    copyq
    orpie
    gthumb
    gitui
  ];
}

