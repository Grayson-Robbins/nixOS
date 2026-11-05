{ config, pkgs, lib, ... }:

{
  options.vpn.enable = lib.mkEnableOption "vpn";

  config = lib.mkMerge [
    # Preserve Vintage Story IPv6 port exceptions regardless of VPN state.
    {
      networking.firewall.extraCommands = ''
        ip6tables -C INPUT -p tcp --dport 42420 -j ACCEPT 2>/dev/null || \
          ip6tables -A INPUT -p tcp --dport 42420 -j ACCEPT

        ip6tables -C INPUT -p udp --dport 42420 -j ACCEPT 2>/dev/null || \
          ip6tables -A INPUT -p udp --dport 42420 -j ACCEPT
      '';
    }

    # VPN enabled
    (lib.mkIf config.vpn.enable {
      networking.firewall = {
        checkReversePath = false;

        # Preserve the existing Vintage Story IPv6 port exceptions.
        extraCommands = ''
          # Create or reuse the IPv4 kill-switch chain.
          iptables -N PROTON_KILLSWITCH 2>/dev/null || true
          iptables -F PROTON_KILLSWITCH

          # Local traffic.
          iptables -A PROTON_KILLSWITCH -o lo -j ACCEPT

          # Tailscale daemon's encrypted outer traffic.
          iptables -A PROTON_KILLSWITCH -m cgroup --path /system.slice/tailscaled.service -j ACCEPT

          # WireGuard-marked traffic.
          iptables -A PROTON_KILLSWITCH -m mark --mark 0xca6c -j ACCEPT

          # Proton WireGuard endpoint traffic (physical interface).
          iptables -A PROTON_KILLSWITCH -d 62.169.136.130/32 -o enp3s0 -p udp --dport 51820 -j ACCEPT
          iptables -A PROTON_KILLSWITCH -d 45.87.214.18/32 -o enp3s0 -p udp --dport 51820 -j ACCEPT

          # Local network and virtual machine networks.
          iptables -A PROTON_KILLSWITCH -d 192.168.1.0/24 -o enp3s0 -j ACCEPT
          iptables -A PROTON_KILLSWITCH -d 192.168.90.0/24 -o vmnet1 -j ACCEPT
          iptables -A PROTON_KILLSWITCH -d 172.16.33.0/24 -o vmnet8 -j ACCEPT

          # Tailscale and Proton interfaces.
          iptables -A PROTON_KILLSWITCH -o tailscale0 -j ACCEPT
          iptables -A PROTON_KILLSWITCH -o proton-secure -j ACCEPT
          iptables -A PROTON_KILLSWITCH -o proton-p2p -j ACCEPT

          # DHCP client traffic.
          iptables -A PROTON_KILLSWITCH -o enp3s0 -p udp --sport 68 --dport 67 -j ACCEPT

          # Everything else is blocked.
          iptables -A PROTON_KILLSWITCH -j DROP

          # Install the jump once, at the beginning of OUTPUT.
          iptables -C OUTPUT -j PROTON_KILLSWITCH 2>/dev/null || \
            iptables -I OUTPUT 1 -j PROTON_KILLSWITCH


          # IPv6 kill switch.
          ip6tables -N PROTON_KILLSWITCH 2>/dev/null || true
          ip6tables -F PROTON_KILLSWITCH

          ip6tables -A PROTON_KILLSWITCH -o lo -j ACCEPT

          # Tailscale daemon's encrypted outer traffic.
          ip6tables -A PROTON_KILLSWITCH -m cgroup --path /system.slice/tailscaled.service -j ACCEPT

          ip6tables -A PROTON_KILLSWITCH -m mark --mark 0xca6c -j ACCEPT

          # IPv6 link-local traffic and neighbor discovery.
          ip6tables -A PROTON_KILLSWITCH -d fe80::/10 -o enp3s0 -j ACCEPT
          ip6tables -A PROTON_KILLSWITCH -o enp3s0 -p ipv6-icmp -j ACCEPT

          # Tailscale and Proton interfaces.
          ip6tables -A PROTON_KILLSWITCH -o tailscale0 -j ACCEPT
          ip6tables -A PROTON_KILLSWITCH -o proton-secure -j ACCEPT
          ip6tables -A PROTON_KILLSWITCH -o proton-p2p -j ACCEPT

          ip6tables -A PROTON_KILLSWITCH -j DROP

          ip6tables -C OUTPUT -j PROTON_KILLSWITCH 2>/dev/null || \
            ip6tables -I OUTPUT 1 -j PROTON_KILLSWITCH
        '';

        # Remove the kill switch completely when the firewall stops.
        extraStopCommands = ''
          while iptables -C OUTPUT -j PROTON_KILLSWITCH 2>/dev/null; do
            iptables -D OUTPUT -j PROTON_KILLSWITCH
          done
          iptables -F PROTON_KILLSWITCH 2>/dev/null || true
          iptables -X PROTON_KILLSWITCH 2>/dev/null || true

          while ip6tables -C OUTPUT -j PROTON_KILLSWITCH 2>/dev/null; do
            ip6tables -D OUTPUT -j PROTON_KILLSWITCH
          done
          ip6tables -F PROTON_KILLSWITCH 2>/dev/null || true
          ip6tables -X PROTON_KILLSWITCH 2>/dev/null || true
        '';
      };

      networking.wg-quick.interfaces = {
        proton-secure = {
          configFile = "/etc/wireguard/proton-secure.conf";
        };

        proton-p2p = {
          configFile = "/etc/wireguard/proton-p2p.conf";
        };
      };

      # Secure Core starts automatically; P2P remains manual.
      systemd.services.wg-quick-proton-secure = {
        wantedBy = [ "multi-user.target" ];
      };

      systemd.services.wg-quick-proton-p2p = {
        wantedBy = lib.mkForce [ ];
      };

      # Preserve Tailscale's more-specific routes in the main table.
      # wg-quick's "suppress_prefixlength 0" rule then allows tailnet
      # traffic to bypass the VPN default route.
      systemd.services.tailscale-proton-routing = {
        description = "Install Tailscale routes alongside Proton VPN";
        wantedBy = [ "multi-user.target" ];
        wants = [ "tailscaled.service" ];
        # TODO: fix warning by deleting "network-online.target" from after list
        after = [ "tailscaled.service" "network-online.target" ];
        partOf = [ "tailscaled.service" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;

          ExecStart = pkgs.writeShellScript "tailscale-proton-routing-start" ''
            for i in $(seq 1 30); do
              if ${pkgs.iproute2}/bin/ip link show tailscale0 >/dev/null 2>&1; then
                break
              fi
              sleep 1
            done

            if ! ${pkgs.iproute2}/bin/ip link show tailscale0 >/dev/null 2>&1; then
              echo "tailscale0 did not appear; cannot install Tailscale routes"
              exit 1
            fi

            ${pkgs.iproute2}/bin/ip route replace 100.64.0.0/10 dev tailscale0 table main
            ${pkgs.iproute2}/bin/ip -6 route replace fd7a:115c:a1e0::/48 dev tailscale0 table main
          '';

          ExecStop = pkgs.writeShellScript "tailscale-proton-routing-stop" ''
            ${pkgs.iproute2}/bin/ip route del 100.64.0.0/10 dev tailscale0 table main 2>/dev/null || true
            ${pkgs.iproute2}/bin/ip -6 route del fd7a:115c:a1e0::/48 dev tailscale0 table main 2>/dev/null || true
          '';
        };
      };

      environment.systemPackages = with pkgs; [
        wireguard-tools
        libnatpmp
        qbittorrent
      ];
    })


      # VPN disabled: explicitly clean up all VPN-specific state.
    (lib.mkIf (!config.vpn.enable) {
      system.activationScripts.vpnDisableCleanup = {
        text = ''
          echo "VPN disabled: cleaning up Proton VPN state"

          # Stop both Proton WireGuard interfaces.
          ${pkgs.systemd}/bin/systemctl stop wg-quick-proton-secure.service || true
          ${pkgs.systemd}/bin/systemctl stop wg-quick-proton-p2p.service || true

          # Stop the route helper, but NOT the Tailscale daemon.
          ${pkgs.systemd}/bin/systemctl stop tailscale-proton-routing.service || true

          # Explicitly remove the custom Tailscale routes.
          ${pkgs.iproute2}/bin/ip route del 100.64.0.0/10 dev tailscale0 table main 2>/dev/null || true
          ${pkgs.iproute2}/bin/ip -6 route del fd7a:115c:a1e0::/48 dev tailscale0 table main 2>/dev/null || true

          # Remove every IPv4 OUTPUT jump to the kill-switch chain.
          while ${pkgs.iptables}/bin/iptables -C OUTPUT -j PROTON_KILLSWITCH 2>/dev/null; do
            ${pkgs.iptables}/bin/iptables -D OUTPUT -j PROTON_KILLSWITCH
          done

          # Flush and remove the IPv4 chain.
          ${pkgs.iptables}/bin/iptables -F PROTON_KILLSWITCH 2>/dev/null || true
          ${pkgs.iptables}/bin/iptables -X PROTON_KILLSWITCH 2>/dev/null || true

          # Remove every IPv6 OUTPUT jump to the kill-switch chain.
          while ${pkgs.iptables}/bin/ip6tables -C OUTPUT -j PROTON_KILLSWITCH 2>/dev/null; do
            ${pkgs.iptables}/bin/ip6tables -D OUTPUT -j PROTON_KILLSWITCH
          done

          # Flush and remove the IPv6 chain.
          ${pkgs.iptables}/bin/ip6tables -F PROTON_KILLSWITCH 2>/dev/null || true
          ${pkgs.iptables}/bin/ip6tables -X PROTON_KILLSWITCH 2>/dev/null || true

          # Stop any leftover qBittorrent processes.
          echo "VPN disabled: stopping qBittorrent"
          ${pkgs.procps}/bin/pkill -TERM -x qbittorrent || true
          ${pkgs.procps}/bin/pkill -TERM -x qbittorrent-nox || true
        '';
      };
    })
  ];
}

