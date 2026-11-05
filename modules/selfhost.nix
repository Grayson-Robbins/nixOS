{ config, lib, pkgs, inputs, ... }:

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
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.services.selfhost = {
    enable = lib.mkEnableOption "self-hosted services infrastructure";

    dataDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/selfhost";
      description = "Root directory for self-hosted service data.";
    };

    immich.enable = lib.mkEnableOption "Immich";
    sure.enable = lib.mkEnableOption "Sure";
    grocy.enable = lib.mkEnableOption "Grocy";
  };

  config = lib.mkIf cfg.enable {
    users.groups.selfhost = {
      gid = 996;
    };

    users.users.selfhost = {
      isSystemUser = true;
      group = "selfhost";
      uid = 996;

      home = cfg.dataDirectory;
      createHome = true;
      homeMode = "0750";

      shell = "${pkgs.shadow}/bin/nologin";
      hashedPassword = "!";

      linger = true;
      autoSubUidGidRange = true;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.selfhost = {
        home.username = "selfhost";
        home.homeDirectory = cfg.dataDirectory;
        home.stateVersion = "24.05";

        xdg.configFile."docker/daemon.json".text = builtins.toJSON {
          dns = [
            "192.168.1.1"
            "8.8.8.8"
          ];
        };

        imports =
          lib.optionals cfg.immich.enable [
            inputs.immich.homeManagerModules.default
          ]
          ++ lib.optionals cfg.sure.enable [
            inputs.sure.homeManagerModules.default
          ]
          ++ lib.optionals cfg.grocy.enable [
            inputs.grocy.homeManagerModules.default
          ];

        services =
          lib.optionalAttrs cfg.immich.enable {
            immich.enable = true;
          }
          // lib.optionalAttrs cfg.sure.enable {
            sure.enable = true;
          }
          // lib.optionalAttrs cfg.grocy.enable {
            grocy.enable = true;
          };
      };
    };

    # Tailscale Serve is host-level configuration, so manage it from
    # the NixOS system service rather than the rootless Docker user.
    systemd.services.selfhost-tailscale-serve = lib.mkIf anyTailscaleServices {
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

