{ config, lib, pkgs, ... }:
{
  imports = [
    ../../modules/nixos/vpn.nix
  ];

  # Desktop-specific Docker DNS config
  services.selfhost.docker.dns = [
    "192.168.1.1"
    "8.8.8.8" # Use external DNS for Sure app
  ];

  # Desktop VPN
  vpn.enable = false;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
    "net.ipv4.conf.enp3s0.rp_filter" = 0;
    "net.ipv4.ip_forward" = 1;  # Enable IP forwarding
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable portal framework
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
  };

  environment.variables.XDG_CURRENT_DESKTOP = "hyprland";

  # Enable WayVNC for remote connections
  environment.systemPackages = [ pkgs.wayvnc ];

  # Open ports in the firewall.

  networking.firewall.allowedTCPPorts = [ 
    11434 # Ollama
    7000  # Odysseus App
    22    # SSH
    80    # Odysseus ntfy
    443   # Tailscale Serve
    9757  # Possibly VR-related, verify later
    8096  # Jellyfin
    5900  # WayVNC
  ];

  networking.firewall.allowedUDPPorts = [ 
    5353  # mDNS / Avahi
    9757  # Possibly VR-related, verify later
    7359  # Jellyfin client discovery
  ];

  # Tailscale daemon config
  services.tailscale.enable = true;

  systemd.services.tailscaled = {
    unitConfig.DefaultDependencies = false;
    wantedBy = [ "initrd.target" ];
    serviceConfig.Environment = [
      "PORT=${toString(config.services.tailscale.port)}"
      ''"FLAGS=--tun ${lib.escapeShellArg config.services.tailscale.interfaceName}"''
    ];
  };
}
