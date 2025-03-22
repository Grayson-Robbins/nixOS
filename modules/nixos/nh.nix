{ pkgs, ... }: {

  environment.sessionVariables = {
    FLAKE = "/home/graysonr/nixOS";
  };

  environment.systemPackages = with pkgs; [
    nh
  ];
}
