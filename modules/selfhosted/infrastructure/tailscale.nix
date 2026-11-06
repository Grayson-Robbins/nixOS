{ config, lib, pkgs, ... }:
let
  cfg = config.services.selfhost;

  tailscale = "${pkgs.tailscale}/bin/tailscale";

  anyTailscaleServices =
    cfg.sure.enable || cfg.immich.enable || cfg.grocy.enable;

  tailscaleServeStart = pkgs.writeShellScript
  "selfhost-tailscale-serve-start" ''
    set -e

    serve_with_retry() {
      local port="$1"
      local target="$2"
      local attempt

      for attempt in $(seq 1 30); do
        if ${tailscale} serve --bg --https="$port" "$target"; then
          return 0
        fi

        echo "Tailscale Serve not ready; retrying ($attempt/30)..."
        sleep 2
      done

      echo "Failed to configure Tailscale Serve on port $port."
      return 1
    }

    ${lib.optionalString cfg.sure.enable ''
      serve_with_retry 443 http://127.0.0.1:3000
    ''}

    ${lib.optionalString cfg.immich.enable ''
      serve_with_retry 8443 http://127.0.0.1:2283
    ''}

    ${lib.optionalString cfg.grocy.enable ''
      serve_with_retry 8444 http://127.0.0.1:9283
    ''}
  '';

  tailscaleServeStop = pkgs.writeShellScript "selfhost-tailscale-serve-stop" (
    ''
      set -eu
    ''
    + lib.optionalString cfg.sure.enable ''
      ${tailscale} serve --https=443 off || true
    ''
    + lib.optionalString cfg.immich.enable ''
      ${tailscale} serve --https=8443 off || true
    ''
    + lib.optionalString cfg.grocy.enable ''
      ${tailscale} serve --https=8444 off || true
    ''
  );
in
{
  config = lib.mkIf (cfg.enable && anyTailscaleServices) {
    # Tailscale Serve is host-level infra. 
    # It runs as system service rather than under the rootless docker user

    systemd.services.selfhost-tailscale-serve = {
      description = "Tailscale Serve routes for self-hosted applications";

      wantedBy = [ "multi-user.target" ];
      requires = [
        "tailscaled.service"
        "network-online.target"
      ];

      after = [
        "network-online.target"
        "tailscaled.service"
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = tailscaleServeStart;
        ExecStop = tailscaleServeStop;
      };
    };
  };
}
