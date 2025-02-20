{ config, lib, pkgs, inputs, ... }: 

{
  programs.qutebrowser = {
    enable = true;
    settings = {
      colors = { };
    };
  };
}

