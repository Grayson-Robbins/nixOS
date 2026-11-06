{ config, lib, inputs, ... }:
let
  cfg = config.services.selfhost;
in
{
  config = lib.mkIf cfg.enable {
    home-manager.users.selfhost = {
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
}
