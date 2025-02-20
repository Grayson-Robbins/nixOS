{ config, lib, pkgs, inputs, ... }: # Accept `inputs` from `extraSpecialArgs`

let 
  wallpaper = pkgs.stdenv.mkDerivation {
    name = "wallpaper";
    src = ./Nature_Wallpaper.jpg;
    phases = [ "installPhase" ];
    installPhase = "cp $src $out";
};
in 
{
  imports = [ inputs.stylix.homeManagerModules.stylix ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    image = wallpaper;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };

    opacity = {
      applications = 1.0;
      terminal = 0.95;
      desktop = 1.0;
      popups = 1.0;
    };

    polarity = "dark";
  };
}

