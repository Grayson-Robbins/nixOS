{ config, lib, pkgs, inputs, ... }: 

{

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Grayson-Robbins"; 
        email = "graysonrobbins17@outlook.com";

      };

      alias = {
        pu = "push";
        co = "checkout";
        cm = "commit";
      };


      # Sign all commits using ssh key
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/github_ed25519.pub";
    };
  };
}

