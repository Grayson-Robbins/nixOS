{ ... }:

{
  imports = [
    ./options.nix
    ./deployments/rootless-docker.nix
    ./applications/home-manager.nix
    ./infrastructure/tailscale.nix
  ];
}
