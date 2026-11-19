{ pkgs, ... }: {

  environment.sessionVariables = {
    NH_FLAKE = "/home/graysonr/nixOS";
  };

  environment.systemPackages = with pkgs; [
    nh
  ];
}
