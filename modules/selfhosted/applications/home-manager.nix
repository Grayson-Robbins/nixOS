
{ config, lib, inputs, ... }:

let
  cfg = config.services.selfhost;
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.selfhost = {
      imports = [
        ../infrastructure/home-manager.nix
      ]
      ++ lib.optionals cfg.immich.enable [
        inputs.immich.homeManagerModules.default
      ]
      ++ lib.optionals cfg.sure.enable [
        inputs.sure.homeManagerModules.default
      ]
      ++ lib.optionals cfg.grocy.enable [
        inputs.grocy.homeManagerModules.default
      ]
      ++ lib.optionals cfg.ollama.enable [
        inputs.ollama.homeManagerModules.default
      ];

      services.selfhost.docker.networks.ai.enable =
        cfg.docker.networks.ai.enable;

      services.selfhost.ollama.enable =
        cfg.ollama.enable;

      services.immich.enable = cfg.immich.enable;
      services.sure.enable = cfg.sure.enable;
      services.grocy.enable = cfg.grocy.enable;
    };
  };
}

