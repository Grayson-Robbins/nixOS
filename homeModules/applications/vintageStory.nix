{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-7.0.20"
  ];

  home.packages = with pkgs; [
    vintagestory
  ];
}
