{ pkgs, lib, ...}:

{
  vim = {
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };
    
    statusline.lualine.enable = true;
    telescope.enable = true;
    autocomplete.nvim-cmp.enable = true;
  

    languages = {
      enableLSP = true;
      enableTreesitter = true;

      nix.enable = true;
      ts.enable = true;
      #python.enable = true;
    };
    
    options = { # Get the tab to go 2 spaces (Finally! :D)
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
    };

    viAlias = true;
    vimAlias = true;
  };
}
