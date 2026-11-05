{ config, pkgs, lib, ... }: {
  options.discord.enable = lib.mkEnableOption "Discord";

  config = lib.mkIf config.discord.enable 
  {
    nixpkgs.config.allowUnfree = true;
    home.packages = with pkgs; [
      discord
    ];
  };
}
