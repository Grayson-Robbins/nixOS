{ lib, ... }:
{
  options.services.selfhost = {
    enable = lib.mkEnableOption "self-hosted services infrastructure";

    dataDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/selfhost";
      description = "Root directory for self-hosted service data.";
    };

    uid = lib.mkOption {
      type = lib.types.int;
      default = 996;
      description = "UID assiged to the selfhost system user.";
    };

    gid = lib.mkOption {
      type = lib.types.int;
      default = 996;
      description = "GID assiged to the selfhost system user.";
    };

    docker.dns = lib.mkOption {
      type = lib.types.listOf 
        lib.types.str;

      default = [];
      example = [ "192.168.1.1" "8.8.8.8" ];
      description = ''
        DNS servers configured for the rootless Docker daemon.
        An empty list leaves DNS configuration to Docker.
      '';
    };

    docker.networks.ai.enable = lib.mkEnableOption "the shared network for self-hosted AI services";


    immich.enable = lib.mkEnableOption "Immich";
    sure.enable = lib.mkEnableOption "Sure";
    grocy.enable = lib.mkEnableOption "Grocy";
    ollama.enable = lib.mkEnableOption "Ollama";
  };
}
