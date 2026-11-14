
{
  description = "Ollama ROCm inference server via rootless Docker";

  outputs = { ... }: {
    homeManagerModules.default = { config, lib, pkgs, ... }:
      let
        cfg = config.services.selfhost.ollama;
        dataDir = "${config.home.homeDirectory}/ollama";

        composeFile = pkgs.writeText "ollama-compose.yaml" ''
          name: ollama

          services:
            ollama:
              image: ollama/ollama:rocm
              container_name: ollama
              restart: unless-stopped

              devices:
                - /dev/kfd:/dev/kfd
                - /dev/dri:/dev/dri

              environment:
                OLLAMA_HOST: "0.0.0.0:11434"

              volumes:
                - ${dataDir}/models:/root/.ollama

              networks:
                - selfhost-ai
              ports:
                - "127.0.0.1:11435:11434"

          networks:
            selfhost-ai:
              external: true
              name: selfhost-ai
        '';

        initialize = pkgs.writeShellScript "ollama-initialize" ''
          set -eu
          mkdir -p ${dataDir}/models
        '';

        composeUp = pkgs.writeShellScript "ollama-compose-up" ''
          set -eu
          export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

          exec ${pkgs.docker}/bin/docker compose \
            --project-directory ${dataDir} \
            -f ${composeFile} \
            up -d
        '';

        composeDown = pkgs.writeShellScript "ollama-compose-down" ''
          set -eu
          export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

          exec ${pkgs.docker}/bin/docker compose \
            --project-directory ${dataDir} \
            -f ${composeFile} \
            down
        '';
      in
      {
        options.services.selfhost.ollama.enable =
          lib.mkEnableOption "the Ollama ROCm inference server";

        config = lib.mkIf cfg.enable {
          systemd.user.services."selfhost-ollama" = {
            Unit = {
              Description = "Ollama ROCm inference server";
              Requires = [
                "docker.service"
                "selfhost-docker-network-ai.service"
              ];
              After = [
                "docker.service"
                "selfhost-docker-network-ai.service"
              ];
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

