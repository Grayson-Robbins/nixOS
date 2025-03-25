{
  description = "Home Manager Flake";

  # These inputs are passed to the configuration.nix file, the hyprland one is used to inform what package the system uses for hyprland
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1"; # Get Hyprland from official flake to give more control when installing plugins (see home.nix file)

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    configuredNvim.url = "github:Grayson-Robbins/nvf-config/master";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, home-manager, stylix, configuredNvim, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages."x86_64-linux".default = configuredNvim.packages."x86_64-linux".default;

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
      ];
    };


    homeConfigurations = {
      graysonr = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

	      modules = [
          ./home.nix
	      ];
        extraSpecialArgs = { inherit inputs; }; # This line passes inputs over to home-manager / home.nix
      };
    };
  };
}
