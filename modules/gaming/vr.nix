{ config, pkgs, lib, ... }:

{
  options.vr.enable = lib.mkEnableOption "VR services";

  config = lib.mkIf config.vr.enable {

    environment.systemPackages = with pkgs; [
      # Used for VR Compatibility
      alvr
      zenity
      libcap
      android-tools # Used for ADB by ALVR
      monado
      xrizer
      opencomposite
    ];

    # For VR Support(?)
    #hardware.steam-hardware.enable = true;
    
    programs.alvr.openFirewall = true;
    services.wivrn = {
      enable = true;
      openFirewall = true;

      steam = {
        enable = true;
        importOXRRuntimes = true;
      };
    };
    services.monado = {
      enable = true;
      defaultRuntime = true; # Register as default OpenXR runtime

    };
      systemd.user.services.monado.environment = {
        STEAMVR_LH_ENABLE = "1";
        XRT_COMPOSITOR_COMPUTE = "1";
      };
  };
}
