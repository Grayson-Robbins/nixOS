# ~/.config/home-manager/home.nix
{ config, pkgs, inputs, ... }: 
	
let
  hyprlandStartupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.swww}/bin/swww init &

    ${pkgs.swww}/bin/swww img ~/Pictures/Nature_Wallpaper.jpg &

    nm-applet --indicator &

    waybar &

    copyq --start-server

    ${pkgs.mako}/bin/mako

  '';
in 
{ 
  imports = [ 
    inputs.nix-colors.homeManagerModules.default 
    ./homeManagerModules/mako.nix
    

  ];
  # Home Manager needs a bit of information about you and the paths it should manage. 
  home.username = "graysonr"; 
  home.homeDirectory = "/home/graysonr"; 
  
  # Setup gtk for desktop/theming, with example config from Vimjoyer's home-manager tutorial
  gtk = {
    enable = true;
    theme.name = "adw-gtk3"; 
    cursorTheme.name = "Bibata-Modern-Ice";
    iconTheme.name = "GruvboxPlus"; 
  };

  # stylix = {
  #   enable = true;
  #   base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  #
  #   image = ../../../Pictures/Nature_Wallpaper.jpg;
  #
  #   cursor = {
  #     package = pkgs.bibata-cursors;
  #     name = "Bibata-Modern-Ice";
  #   };

    # fonts = {
    #   monospace = {
    #     package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
    #     name = "JetBrainsMono Nerd Font Mono";
    #   };
    #   sansSerif = {
    #     package = pkgs.dejavu_fonts;
    #     name = "DejaVu Sans";
    #   };
    #   serif = {
    #     package = pkgs.dejavu_fonts;
    #     name = "DejaVu Serif";
    #   };
    #
    #   # sizes = {
    #   #   applications = 12;
    #   #   terminal = 15;
    #   #   desktop = 10;
    #   #   popups = 10;
    #   # };
    # };

    # polarity = "dark";

    # opacity = {
    #   applications = 1.0;
    #   terminal = 0.85;
    #   desktop = 1.0;
    #   popups = 1.0;
    # };
  #   targets = {
  #     gtk.enable = false;
  #     gnome.enable = false;
  #   };
  # };
  
  
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-7.0.20"
  ];
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.


  # colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium; # Example scheme used in nix-colors github readme
  programs.kitty = {
    enable = true;
    settings = {
      # foreground = "#${config.palette.base05}";
      # background = "#${config.palette.base00}";
    };
  };


  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # Set monitor settings
      monitor = [
        "DP-1, 2560x1440@144, 0x0,1"
	"DP-2, 2560x1440@144, 2560x0, 1"
      ];

      "$terminal" = "kitty"; # Declare terminal
      "$fileManager" = "dolphin"; # Declare file manager
      "$menu" = "wofi --show drun --allow-images"; # Declare app run menu

      env = [
        "XCURSOR_SIZE, 24"
	"HYPRCURSOR_SIZE, 24"
	"LIBVA_DRIVER_NAME,nvidia"
	"__GLX_VENDOR_LIBRARY_NAME,nvidia"
	"ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];

      general = with config.palette; {
        # "col.active_border" = "rgba(${base0E}ff) rgba(${base09}ff) 60deg";
	# "col.inactive_border" = "rgba(${base00}ff)";
	resize_on_border = "false";
	layout = "dwindle";
	gaps_in = "5";
	gaps_out = "20";
	border_size = "2";
      };

      decoration = {
 	rounding = "10";
	active_opacity = "1.0";
	inactive_opacity = "1.0";

	shadow = {
	  enabled = "true";
	  range = "4";
	  render_power = "3";
	  color = "rgba(1a1a1aee)";
	};

	blur = {
	  enabled = "true";
	  size = "3";
	  passes = "1";
	  vibrancy = "0.1696";
	};

      };

      animations = {
        enabled = "yes, please :)";

	bezier = [
   	  "easeOutQuint,0.23,1,0.32,1"
	  "easeInOutCubic,0.65,0.05,0.36,1"
	  "linear,0,0,1,1"
	  "almostLinear,0.5,0.5,0.75,1.0"
	  "quick,0.15,0,0.1,1"
	];

	animation = [
  	  "global, 1, 10, default"
	  "border, 1, 5.39, easeOutQuint"
	  "windows, 1, 4.79, easeOutQuint"
	  "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
	  "windowsOut, 1, 1.49, linear, popin 87%"
	  "fadeIn, 1, 1.73, almostLinear"
	  "fadeOut, 1, 1.46, almostLinear"
	  "fade, 1, 3.03, quick"
	  "layers, 1, 3.81, easeOutQuint"
	  "layersIn, 1, 4, easeOutQuint, fade"
	  "layersOut, 1, 1.5, linear, fade"
	  "fadeLayersIn, 1, 1.79, almostLinear"
	  "fadeLayersOut, 1, 1.39, almostLinear"
	  "workspaces, 1, 1.94, almostLinear, fade"
	  "workspacesIn, 1, 1.21, almostLinear, fade"
	  "workspacesOut, 1, 1.94, almostLinear, fade"
	];
      };

      dwindle = {
        pseudotile = "true";
	preserve_split = "true";
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = "0";
	disable_hyprland_logo = "true";
      };

      input = {
        kb_layout = "us";
	follow_mouse = "1";
	sensitivity = "0";
	touchpad.natural_scroll = "false";
      };

      gestures.workspace_swipe = "false";

      device = {
	name = "epic-mouse-v1";
	sensitivity = "-0.5";
      };

      "$mod" = "SUPER";

      bind = [
	"$mod, Q, exec, $terminal"
	"$mod, C, killactive"
	"$mod, M, exit"
	"$mod, E, exec, $fileManager"
	"$mod, F, togglefloating"
	"$mod, R, exec, $menu"
	"$mod, P, pseudo"
	"$mod, J, togglesplit"
	
	# Move focus with mod + arrow keys
	"$mod, left, movefocus, l"
	"$mod, right, movefocus, r"
	"$mod, up, movefocus, u"
	"$mod, down, movefocus, d"

	# Switch workspaces with mod + 0-9
	"$mod, 1, workspace, 1"
	"$mod, 2, workspace, 2"
	"$mod, 3, workspace, 3"
	"$mod, 4, workspace, 4"
	"$mod, 5, workspace, 5"
	"$mod, 6, workspace, 6"
	"$mod, 7, workspace, 7"
	"$mod, 8, workspace, 8"
	"$mod, 9, workspace, 9"
	"$mod, 0, workspace, 10"

	# Move active window to a workspace with mod + SHIFT + 0-9
	"$mod SHIFT, 1, movetoworkspace, 1"
	"$mod SHIFT, 2, movetoworkspace, 2"
	"$mod SHIFT, 3, movetoworkspace, 3"
	"$mod SHIFT, 4, movetoworkspace, 4"
	"$mod SHIFT, 5, movetoworkspace, 5"
	"$mod SHIFT, 6, movetoworkspace, 6"
	"$mod SHIFT, 7, movetoworkspace, 7"
	"$mod SHIFT, 8, movetoworkspace, 8"
	"$mod SHIFT, 9, movetoworkspace, 9"
	"$mod SHIFT, 0, movetoworkspace, 10"

	# Example special workspace (scratchpad)
	"$mod, S, togglespecialworkspace, magic"
	"$mod SHIFT, S, movetoworkspace, special:magic"

	# Scroll through existing workspaces with mod + scroll
	"$mod, mouse_down, workspace, e+1"
	"$mod, mouse_up, workspace, e-1"

	# Copyq clipboard manager bind
	"$mod, V, exec, copyq"
      ];

      bindm = [
	# Move/resize windows with mod + LMB/RMB and dragging
	"$mod, mouse:272, movewindow"
	"$mod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
      	# Ignore maximize requests from apps
	"suppressevent maximize, class:.*"

	# Fix some dragging issues with XWayland
	"nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      workspace = [
        "1, monitor:DP-1, default:true"
	"2, monitor:DP-2, default:true"
 
      ];

      exec-once = ''${hyprlandStartupScript}/bin/start'';
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    qutebrowser
    discord
#    nerd-fonts.IBMPlexMono
    nerd-fonts.iosevka
#    qimgv
#    nerd-fonts.IosevkaTerm
    pkgs.vintagestory
    ollama
    lagrange
    #clipse
    copyq
    pavucontrol # PulseAudio Volume Control
    bottom # TUI system monitor
    orpie # TUI RPN Calculator
    dolphin
    gthumb
    wl-clipboard
    gitui

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/graysonr/etc/profile.d/hm-session-vars.sh
  #

 # Setup nix-colors for home-manager
  # imports = [
  #   nix-colors.homeManagerModules.default
  #   #nixvim.homeManagerModules.nixvim
  # ];
  #

  # Declare programs and their configs
  programs = {
    qutebrowser = {
      enable = true;
      settings = {
        colors = {
          # Becomes either 'dark' or 'light', based on colors!
   	  webpage.preferred_color_scheme = "${config.variant}"; # I don't believe this line works
	 # webpage.bg = "${config.variant}";
   	  # tabs.bar.bg = "#${config.palette.base00}";
   	  # keyhint.fg = "#${config.palette.base05}";
	  # hints.bg = "#${config.palette.base05}";
        };
      };
    };

    git = {
      enable = true; # Enable git (Already enabled system-wide, but still)
      userName = "gar0018"; # Set my userName to avoid needing to enter it consistently
      userEmail = "gar0018@uah.edu"; # Set email, see above
      aliases = { # Some example aliases from Vimjoyer's Nix home-manager tutorial
        pu = "push";
        co = "checkout";
        cm = "commit";
      };
    };

    nvf = {
      enable = true;
      enableManpages = true; # Allows for viewing documentation via "man 5 nvf"

      settings.vim = {
        viAlias = true;
	vimAlias = true;
	lsp = {
	  enable = true;
	};
       
        # This works to set things you'd normally set in options.lua that you can't set elsewhere
        luaConfigRC.optionsScript = ''
          vim.g.mapleader = ' '
          vim.g.maplocalleader = ' '
          vim.o.tabstop = 4
          vim.o.shiftwidth = 4
        '';


        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };

        optPlugins = [ 
            pkgs.vimPlugins.nui-nvim 
            pkgs.vimPlugins.vim-tmux-navigator 
        ]; # This adds the plugin nui-nvim, required for ChatGPT
        
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
    
    yazi = {
      enable = true;
      settings.manager.show_hidden = true;
    };
  };




  home.sessionVariables = {
   #  EDITOR = "nvim";

     # Below are some settings to help Hyprland run
     #WLR_NO_HARDWARE_CURSORS = "1"; # Enable this if using wayland/hyprland causes an invisible cursor
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
