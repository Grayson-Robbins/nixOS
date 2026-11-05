{
  description = "Immich rootless Docker deployment for Home Manager";

  outputs = { ... }: {
    homeManagerModules.default = { config, lib, pkgs, ... }:
      let
        cfg = config.services.immich;
        dataDir = "${config.home.homeDirectory}/immich";

        composeFile = pkgs.writeText "immich-compose.yaml" ''
          name: immich

          services:
            immich-server:
              container_name: immich_server
              image: ghcr.io/immich-app/immich-server:''${IMMICH_VERSION:-release}
              security_opt:
                - no-new-privileges:true
              cap_drop:
                - NET_RAW
              volumes:
                - ${dataDir}/library:/data
                - /etc/localtime:/etc/localtime:ro
              env_file:
                - ${dataDir}/immich.env
              ports:
                - "127.0.0.1:2283:2283"
              depends_on:
                - redis
                - database
              restart: always

            immich-machine-learning:
              container_name: immich_machine_learning
              image: ghcr.io/immich-app/immich-machine-learning:''${IMMICH_VERSION:-release}
              user: "1000:1000"
              security_opt:
                - no-new-privileges:true
              cap_drop:
                - NET_RAW
              volumes:
                - model-cache:/cache
              env_file:
                - ${dataDir}/immich.env
              restart: always

            redis:
              container_name: immich_redis
              image: docker.io/valkey/valkey:9
              security_opt:
                - no-new-privileges:true
              cap_drop:
                - NET_RAW
              healthcheck:
                test: ["CMD", "valkey-cli", "ping"]
              restart: always

            database:
              container_name: immich_postgres
              image: ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0
              security_opt:
                - no-new-privileges:true
              cap_drop:
                - NET_RAW
              environment:
                POSTGRES_PASSWORD: ''${DB_PASSWORD}
                POSTGRES_USER: ''${DB_USERNAME}
                POSTGRES_DB: ''${DB_DATABASE_NAME}
                POSTGRES_INITDB_ARGS: "--data-checksums"
              volumes:
                - ${dataDir}/postgres:/var/lib/postgresql/data
              shm_size: 128mb
              restart: always

          volumes:
            model-cache:
        '';

        composeUp = pkgs.writeShellScript "immich-compose-up" ''
          set -eu
          export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
          exec ${pkgs.docker}/bin/docker compose \
            --project-directory ${dataDir} \
            --env-file ${dataDir}/immich.env \
            -f ${composeFile} \
            up -d
        '';

        composeDown = pkgs.writeShellScript "immich-compose-down" ''
          set -eu
          export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
          exec ${pkgs.docker}/bin/docker compose \
            --project-directory ${dataDir} \
            --env-file ${dataDir}/immich.env \
            -f ${composeFile} \
            down
        '';
      in
      {
        options.services.immich.enable = lib.mkEnableOption
          "the Immich self-hosted image drive";
        config = lib.mkIf cfg.enable { 
          systemd.user.services.immich = {
            Unit = {
              Description = "Immich photo library";
              Requires = [ "docker.service" ];
              After = [ "docker.service" ];
            };

            Service = {
              Type = "oneshot";
              RemainAfterExit = true;
              Environment = [ "DOCKER_HOST=unix://%t/docker.sock" ];
              ExecStartPre = [
                "${pkgs.coreutils}/bin/mkdir -p ${dataDir}/library ${dataDir}/postgres ${dataDir}/redis"
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

