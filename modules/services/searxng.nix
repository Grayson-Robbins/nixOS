
{ config, lib, pkgs, ... }:

{
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    redisCreateLocally = true;
    openFirewall = false;

    environmentFile = "/var/lib/searx/searx.env";

    settings = {
      use_default_settings = true;

      general = {
        debug = false;
        instance_name = "Local SearXNG";
      };

      server = {
        bind_address = "127.0.0.1";
        port = 8888;
        secret_key = "$SEARX_SECRET_KEY";
        limiter = false;
        public_instance = false;
      };

      search.formats = [
        "html"
        "json"
      ];
    };
  };

  # Create the secret locally, rather than embedding it in the
  # Nix store or requiring a manual secret-generation step.
  systemd.services.searx-secret = {
  description = "Generate SearXNG secret key";

  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;

    # Persistent directory for the generated environment file.
    StateDirectory = "searx";
    StateDirectoryMode = "0700";
  };

  script = ''
    set -eu

    secret_file=/var/lib/searx/searx.env

    if [ ! -s "$secret_file" ]; then
      umask 077
      printf 'SEARX_SECRET_KEY=%s\n' \
        "$(${pkgs.openssl}/bin/openssl rand -hex 32)" \
        > "$secret_file"
    fi

    chmod 0600 "$secret_file"
  '';
};

systemd.services.searx-init = {
  requires = [ "searx-secret.service" ];
  after = [ "searx-secret.service" ];
};
}

