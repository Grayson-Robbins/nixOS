{
    description = "Odysseus development environment";

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
      devShells.${system}.default = pkgs.mkShell {

        packages = [
          pkgs.python313
          pkgs.python313Packages.pip
          pkgs.python313Packages.virtualenv

          pkgs.nodejs
          pkgs.git
        ];

      shellHook = ''
          echo "Odysseus development shell"

          if [ ! -d .venv ]; then
            python -m venv .venv
            echo "Created virtual environment"
          fi

          source .venv/bin/activate

          echo "Python:"
          python --version
        '';
      };
  };
}
