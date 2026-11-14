{ config, lib, pkgs, ... }:

let
  cfg = config.services.selfhost.docker.networks.ai;

  networkName = "selfhost-ai";

  ensureNetwork = pkgs.writeShellScript "selfhost-ai-network" ''
    set -eu

    export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

    if ! ${pkgs.docker}/bin/docker network inspect ${networkName} >/dev/null 2>&1; then
      ${pkgs.docker}/bin/docker network create ${networkName}
    fi
  '';
in
{
  options.services.selfhost.docker.networks.ai.enable =
    lib.mkEnableOption "the shared self-hosted AI Docker network";

  config = lib.mkIf cfg.enable {
    systemd.user.services.selfhost-docker-network-ai = {
      Unit = {
        Description = "Shared Docker network for self-hosted AI services";
        Requires = [ "docker.service" ];
        After = [ "docker.service" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = [
          "DOCKER_HOST=unix://%t/docker.sock"
        ];
        ExecStart = ensureNetwork;
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
