{ pkgs }:

pkgs.writeShellScriptBin "my-awesome-script" ''
  echo "hello world" | ${pkgs.cowsay}/bin/cowsay | ${pkgs.lolcat}/bin/lolcat
'' # use pkgs.name syntax to find nix store location of package, NOTE in /bin/ the package name/executable may not always match the name in pkgs.name
