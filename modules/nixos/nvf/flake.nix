{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = { self, nvf, nixpkgs, ... }: 
  let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
  in
  {
    packages."x86_64-linux".configuredNvim = 
      (nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [
          ./nvf-configuration.nix
        ];

      }).neovim;

    packages.x86_64-linux.default = self.outputs.packages."x86_64-linux".configuredNvim;
  };
}
