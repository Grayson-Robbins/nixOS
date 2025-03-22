{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.nvf.homeManagerModules.default ]; # Import NVF module

  programs.nvf = {
    enable = true;
    enableManpages = true;

    settings.vim = {
      viAlias = true;
      vimAlias = true;
      lsp.enable = true;
      
      luaConfigRC.optionsScript = ''
        vim.g.mapleader = ' '
        vim.g.maplocalleader = ' '
        vim.o.tabstop = 4
        vim.o.shiftwidth = 4
      '';

      theme = {
        enable = true;
        name = lib.mkForce "gruvbox";
        style = "dark";
      };

      optPlugins = [ 
        pkgs.vimPlugins.nui-nvim 
        pkgs.vimPlugins.vim-tmux-navigator 
      ];
      statusline.lualine.enable = true;
      telescope.enable = true;
      autocomplete.nvim-cmp.enable = true;
      comments.comment-nvim.enable = true; # Allows for comment shortcuts (gcc for line, gbc for block)

      languages = { # This Code enables treesitter and LSP for given languages
        enableLSP = true;
        enableTreesitter = true;

        nix.enable = true;
        ts.enable = true;
        python.enable = true;
        lua.enable = true;
      };

      filetree.neo-tree.enable = true;
      assistant.chatgpt.enable = true;
    };
  };
}

