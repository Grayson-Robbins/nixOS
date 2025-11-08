{ config, lib, pkgs, inputs, ... }: 

{

  programs.git = {
    enable = true;
    userName = "Grayson-Robbins"; 
    userEmail = "graysonrobbins17@outlook.com"; 
    aliases = {
      pu = "push";
      co = "checkout";
      cm = "commit";
    };
    extraConfig = {
	# Sign all commits using ssh key
	commit.gpgsign = true;
	gpg.format = "ssh";
	user.signingkey = "~/.ssh/github_ed25519.pub";
    };
  };
}

