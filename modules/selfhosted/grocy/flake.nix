
{
  description = "Grocy household management via rootless Docker";

  outputs = { ... }: {
    homeManagerModules.default = { config, lib, pkgs, ... }:
      let
        cfg = config.services.grocy;
        dataDir = "${config.home.homeDirectory}/grocy";

        composeFile = pkgs.writeText "grocy-compose.yaml" ''
          name: grocy

          services:
            grocy:
              image: lscr.io/linuxserver/grocy:${cfg.imageTag}
              container_name: grocy
              restart: unless-stopped

              security_opt:
                - no-new-privileges:true

              cap_drop:
                - NET_RAW

              environment:
                PUID: "${toString cfg.uid}"
                PGID: "${toString cfg.gid}"
                TZ: "${cfg.timeZone}"

              volumes:
                - grocy-config:/config

              ports:
                - "127.0.0.1:${toString cfg.port}:80"

          volumes:
            grocy-config:
              name: grocy-config
        '';

        composeUp = pkgs.writeShellScript "grocy-compose-up" ''
          set -eu

          export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

          exec ${pkgs.docker}/bin/docker compose \
            --project-directory ${dataDir} \
            -f ${composeFile} \
            up -d
        '';

        composeDown = pkgs.writeShellScript "grocy-compose-down" ''
          set -eu

          export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

          exec ${pkgs.docker}/bin/docker compose \
            --project-directory ${dataDir} \
            -f ${composeFile} \
            down
        '';

      in
      {
        options.services.grocy = {
          enable = lib.mkEnableOption "the Grocy household management application";

          port = lib.mkOption {
            type = lib.types.port;
            default = 9283;
            description = "Host port used to access Grocy.";
          };

          imageTag = lib.mkOption {
            type = lib.types.str;
            default = "4.7.1";
            description = "LinuxServer Grocy container image tag.";
          };

          timeZone = lib.mkOption {
            type = lib.types.str;
            default = "America/Chicago";
            description = "Container timezone.";
          };

          uid = lib.mkOption {
            type = lib.types.int;
            default = 1000;
            description = "PUID used by the LinuxServer container.";
          };

          gid = lib.mkOption {
            type = lib.types.int;
            default = 1000;
            description = "PGID used by the LinuxServer container.";
          };
        };

        config = lib.mkIf cfg.enable {
          systemd.user.services.grocy = {
            Unit = {
              Description = "Grocy household management";
              Requires = [ "docker.service" ];
              After = [ "docker.service" ];
            };

            Service = {
              Type = "oneshot";
              RemainAfterExit = true;

              Environment = [
                "DOCKER_HOST=unix://%t/docker.sock"
              ];

              ExecStartPre = [
                "${pkgs.coreutils}/bin/mkdir -p ${dataDir}"
              ];

              ExecStart = composeUp;
              ExecStop = composeDown;
            };

            Install.WantedBy = [ "default.target" ];
          };
        };
      };
  };
}

