{
  description = "Flake for managing development shells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:

  let 
    pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; }; # To allow VSCode into the shell
  in
  {
   # pkgs.writeShellScriptBin "vscode-compat" ''
   #   ${pkgs.vscode}/bin/code --

   # ''

    devShells."x86_64-linux" = { 
      aida = import ./aida.nix { inherit pkgs; }; # When "nix develop .#aida" is run in terminal, launch aida dev shell
      rankbot = import ./rankbot.nix { inherit pkgs; }; # When "nix develop .#rankbot" is run in terminal, launch rankbot dev shell
    };
  };

}
