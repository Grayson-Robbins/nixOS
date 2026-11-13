{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.services.selfhost;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = lib.mkIf cfg.enable {
    # Dedicated system user for self-hosted apps
    users.users.selfhost = {
      isSystemUser = true;
      group = "selfhost";
      uid = cfg.uid;

      home = cfg.dataDirectory;
      createHome = true;
      homeMode = "0750";

      shell = "${pkgs.shadow}/bin/nologin";
      hashedPassword = "!";

      linger = true;
      autoSubUidGidRange = true;
    };

    users.groups.selfhost = {};

    # Rootless Docker runtime
    virtualisation.docker = {
      enable = false;

      rootless = {
        enable = true;
        setSocketVariable = true;

        daemon.settings = lib.mkIf (cfg.docker.dns != []) {
          dns = cfg.docker.dns;
        };
      };
    };

    # Home Manager integration for dedicated service user
    home-manager = {
      # If later use home-manager for unrelated users, may want to move these two to host-level config
      useGlobalPkgs = true;
      useUserPackages = true;

      users.selfhost = {
        home.username = "selfhost";
        home.homeDirectory = cfg.dataDirectory;
        home.stateVersion = "24.05";
      };
    };

    # Optional Docker daemon DNS config
    #home-manager.users.selfhost.xdg.configFile = 
    #  lib.mkIf (cfg.docker.dns != []) {
    #    "docker/daemon.json".text = builtins.toJSON {
    #      dns = cfg.docker.dns;
    #    };
    #  };
  };
}
