{ config, lib, pkgs, inputs, ... }: 

{
  programs.tmux = {
    enable = true;
    shortcut = "Space";
    baseIndex = 0;
    newSession = true;
    escapeTime = 0;
    secureSocket = false;

    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      vim-tmux-navigator # Allows for vim keybinds for changing panes. Must be installed as neovim plugin as well
      gruvbox
      yank
    ];

    extraConfig = ''
      set-option -g mouse on
      # easy-to-remember split pane commands, also ensure new panes/windows open in same directory as parent
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };
  
  # Allows for ssh'ing into a tmux session, looks like
 # programs.tmate.enable = true;

  home.packages = [
    # Open tmux for current project.
    (pkgs.writeShellApplication {
      name = "pux";
      runtimeInputs = [ pkgs.tmux ];
      text = ''
        PRJ="''$(zoxide query -i)"
	echo "Launching tmux for ''$PRJ"
	set -x
	cd "''$PRJ" && \
	  exec tmux -S "''$PRJ".tmux attach
      '';
    })
  ];

}

