{
    description = "Odysseus development environments";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
      let
        system = "x86_64-linux";

      pkgs = import nixpkgs {
          inherit system;
        };

      in {

        devShells.${system} = {

          uv = import ./shells/uv.nix {
            inherit pkgs;
          };

        pip = import ./shells/pip.nix {
            inherit pkgs;
          };

        };

    };
}
