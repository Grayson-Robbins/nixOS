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
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake.url = "github:sodiboo/niri-flake";

    vintagestory-nix = {
      url = "git+https://codeberg.org/PierreBorine/vintagestory-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vs2nix = {
      url = "github:dtomvan/vs2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, niri-flake, configuredNvim, vs2nix, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    packages."x86_64-linux".default = configuredNvim.packages."x86_64-linux".default;
    packages."x86_64-linux".myModsDir = vs2nix.legacyPackages.${system}.makeVintageStoryModsDir "my-modpack-3000" (mods: with mods; [
        # run `nix flake show github:dtomvan/vs2nix` for the mod names
        carryon

    ]);

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
