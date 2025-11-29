{ config, lib, pkgs, ... }:

let
  vsServerPkg = pkgs.callPackage ./vintagestory-server-package.nix {};
in
{
  options.services.vintagestory-server = {
    enable = lib.mkEnableOption "Vintage Story Dedicated Server";

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/vintagestory";
      description = "Directory where world data, logs, and config are stored.";
    };

    configJson = lib.mkOption {
      type = lib.types.str;
      default = ''
        {
          "maxPlayers": 16,
          "serverPort": 42420
        }
      '';
      description = "Contents of server's config.json file.";
    };
  };

  config = lib.mkIf config.services.vintagestory-server.enable {

    # --- User & Group ---
    users.groups.vintagestory = {};

    users.users.vintagestory = {
      isSystemUser = true;
      group = "vintagestory";
      home = config.services.vintagestory-server.dataDir;
      createHome = true;

      shell = pkgs.bash;
    };

    # --- Ensure data directory + config.json exist ---
    systemd.tmpfiles.rules = [
      "d ${config.services.vintagestory-server.dataDir} 0750 vintagestory vintagestory -"
      "f ${config.services.vintagestory-server.dataDir}/config.json 0640 vintagestory vintagestory - ${config.services.vintagestory-server.configJson}"
    ];

    # --- Systemd Service ---
    systemd.services.vintagestory-server = {
    description = "Vintage Story Dedicated Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
        User = "vintagestory";
        Group = "vintagestory";
        WorkingDirectory = config.services.vintagestory-server.dataDir;

        ExecStart = "${pkgs.dotnetCorePackages.runtime_8_0}/bin/dotnet ${vsServerPkg}/VintagestoryServer.dll";

        ExecStartPre = [
          ''
            ${pkgs.bash}/bin/bash -c "printf '/serverconfig whitelistmode off\n' > /var/lib/vintagestory/.config/VintagestoryData/servercommands.txt"
          ''
        ];


        Restart = "always";
        RestartSec = 5;
      };
    };

  };
}

