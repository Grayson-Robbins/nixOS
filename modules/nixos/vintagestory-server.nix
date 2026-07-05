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

    whitelist = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "Nomad7824" ];
      description = "List of players to add to the server whitelist.";
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

    # --- Ensure data directory, config.json, and servercommands.txt exist ---
    systemd.tmpfiles.rules = [
  "d /var/lib/vintagestory 0750 vintagestory vintagestory -"
  "f /var/lib/vintagestory/config.json 0640 vintagestory vintagestory - ${config.services.vintagestory-server.configJson}"
  "d /var/lib/vintagestory/.config/VintagestoryData 0750 vintagestory vintagestory -"
  "f /var/lib/vintagestory/.config/VintagestoryData/servercommands.txt 0640 vintagestory vintagestory - /serverconfig whitelistmode off\n/serverconfig addplayer Nomad7824"
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

        # Bind to both IPv4 and IPv6 (::) to allow external connections
        ExecStart = "${pkgs.dotnetCorePackages.runtime_8_0}/bin/dotnet ${vsServerPkg}/VintagestoryServer.dll";

        Restart = "always";
        RestartSec = 5;

        # Network access settings - make sure these aren't restrictive
        PrivateNetwork = false;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      };
    };
  };
}

