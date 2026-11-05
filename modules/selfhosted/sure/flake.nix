{
  description = "Sure financial planner via rootless Docker";

  outputs = { ... }: {
    homeManagerModules.default = { config, lib, pkgs, ... }:
      let
        cfg = config.services.sure;
        dataDir = "${config.home.homeDirectory}/sure";

        composeFile = pkgs.writeText "sure-compose.yaml" ''
          name: sure

          x-db-env: &db-env
            POSTGRES_USER: "sure_user"
            POSTGRES_PASSWORD: ''${POSTGRES_PASSWORD}
            POSTGRES_DB: "sure_production"

          x-rails-env: &rails-env
            <<: *db-env
            SECRET_KEY_BASE: ''${SECRET_KEY_BASE}
            SELF_HOSTED: "true"
            RAILS_FORCE_SSL: "false"
            RAILS_ASSUME_SSL: "false"
            DB_HOST: "db"
            DB_PORT: "5432"
            REDIS_URL: "redis://redis:6379/1"
            ONBOARDING_STATE: ''${ONBOARDING_STATE:-open}
            ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY: ''${ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY}
            ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY: ''${ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY}
            ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT: ''${ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT}
            PLAID_CLIENT_ID: ''${PLAID_CLIENT_ID}
            PLAID_SECRET: ''${PLAID_SECRET}
            PLAID_ENV: ''${PLAID_ENV}

          services:
            web:
              image: ghcr.io/we-promise/sure:''${SURE_IMAGE_TAG:-stable}
              restart: unless-stopped
              ports:
                - "127.0.0.1:''${PORT:-3000}:3000"
              volumes:
                - app-storage:/rails/storage
              environment:
                <<: *rails-env
              depends_on:
                db:
                  condition: service_healthy
                redis:
                  condition: service_healthy
              networks:
                - sure-net

            worker:
              image: ghcr.io/we-promise/sure:''${SURE_IMAGE_TAG:-stable}
              command: bundle exec sidekiq
              restart: unless-stopped
              volumes:
                - app-storage:/rails/storage
              environment:
                <<: *rails-env
              depends_on:
                db:
                  condition: service_healthy
                redis:
                  condition: service_healthy
              networks:
                - sure-net

            db:
              image: postgres:16
              restart: unless-stopped
              volumes:
                - postgres-data:/var/lib/postgresql/data
              environment:
                <<: *db-env
              healthcheck:
                test:
                  - CMD-SHELL
                  - pg_isready -U "$$POSTGRES_USER" -d "$$POSTGRES_DB"
                interval: 5s
                timeout: 5s
                retries: 5
              networks:
                - sure-net

            redis:
              image: redis:7
              restart: unless-stopped
              volumes:
                - redis-data:/data
              healthcheck:
                test: ["CMD", "redis-cli", "ping"]
                interval: 5s
                timeout: 5s
                retries: 5
              networks:
                - sure-net

          volumes:
            app-storage:
            postgres-data:
            redis-data:

          networks:
            sure-net:
              driver: bridge
        '';

        initialize = pkgs.writeShellScript "sure-initialize" ''
          set -eu
          umask 077

          mkdir -p ${dataDir}
          chmod 700 ${dataDir}

          if [ ! -e ${dataDir}/.env ]; then
            secret="$(${pkgs.openssl}/bin/openssl rand -hex 64)"
            db_password="$(${pkgs.openssl}/bin/openssl rand -hex 32)"

            {
              printf 'SECRET_KEY_BASE=%s\n' "$secret"
              printf 'POSTGRES_PASSWORD=%s\n' "$db_password"
              printf 'SURE_IMAGE_TAG=stable\n'
              printf 'PORT=3000\n'
              printf 'ONBOARDING_STATE=open\n'
            } > ${dataDir}/.env

            chmod 600 ${dataDir}/.env
          fi
        '';

        composeUp = pkgs.writeShellScript "sure-compose-up" ''
          set -eu
          export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

          exec ${pkgs.docker}/bin/docker compose \
            --project-directory ${dataDir} \
            --env-file ${dataDir}/.env \
            -f ${composeFile} \
            up -d
        '';

        composeDown = pkgs.writeShellScript "sure-compose-down" ''
          set -eu
          export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

          exec ${pkgs.docker}/bin/docker compose \
            --project-directory ${dataDir} \
            --env-file ${dataDir}/.env \
            -f ${composeFile} \
            down
        '';
      in
      {
        options.services.sure.enable = lib.mkEnableOption
          "the Sure self-hosted financial planner";

        config = lib.mkIf cfg.enable {
          systemd.user.services.sure = {
            Unit = {
              Description = "Sure financial planner";
              Requires = [ "docker.service" ];
              After = [ "docker.service" ];
            };

            Service = {
              Type = "oneshot";
              RemainAfterExit = true;
              Environment = [
                "DOCKER_HOST=unix://%t/docker.sock"
              ];
              ExecStartPre = [ initialize ];
              ExecStart = composeUp;
              ExecStop = composeDown;
            };

            Install.WantedBy = [ "default.target" ];
          };
        };
      };
  };
}

