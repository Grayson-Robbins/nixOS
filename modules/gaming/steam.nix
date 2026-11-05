{ lib, pkgs, config, ... }:
let 
  cfg = config.gaming.steam;
in
{
  options.gaming.steam.enable = lib.mkEnableOption "Steam";

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.steam.extraPackages = [ pkgs.hidapi ];

    programs.gamemode.enable = true;
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/graysonr/.steam/root/compatibilitytools.d";
    };
    environment.systemPackages = with pkgs; [
      protonup-ng
    ];

  };
}
