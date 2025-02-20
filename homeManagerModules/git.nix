{ config, lib, pkgs, inputs, ... }: 

{
  programs.git = {
    enable = true;
    userName = "gar0018"; 
    userEmail = "gar0018@uah.edu"; 
    aliases = {
      pu = "push";
      co = "checkout";
      cm = "commit";
    };
  };
}

