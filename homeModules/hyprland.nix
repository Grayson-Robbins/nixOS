{ config, lib, pkgs, inputs, ... }: 

let
  hyprlandStartupScript = pkgs.writeShellScriptBin "start" ''
    ${pkgs.swww}/bin/swww init &
    ${pkgs.swww}/bin/swww img ~/Pictures/Nature_Wallpaper.jpg &
    nm-applet --indicator &
    waybar &
    copyq --start-server &
    ${pkgs.mako}/bin/mako
  '';
in
{
  imports = [ inputs.hyprland.homeManagerModules.default ];

  wayland.windowManager.hyprland = {
    enable = true;

    xwayland.enable = true;

    settings = {
      monitor = [
        "DP-2, 2560x1440@144, 0x0,1"
        "DP-1, 2560x1440@144, 2560x0, 1"
      ];

      "$terminal" = "kitty"; 
      "$fileManager" = "dolphin"; 
      "$menu" = "wofi --show drun --allow-images"; 
 env = [
        "XCURSOR_SIZE, 24"
	"HYPRCURSOR_SIZE, 24"
	"LIBVA_DRIVER_NAME,nvidia"
	"__GLX_VENDOR_LIBRARY_NAME,nvidia"
	"ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];

      general = /*with config.colorScheme.palette;*/ {
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
	  # color = "rgba(1a1a1aee)";
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
        #disable_hyprland_logo = "true";
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
	# "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      workspace = [
        "1, monitor:DP-1, default:true"
	"2, monitor:DP-2, default:true"
 
      ];

      exec-once = ''${hyprlandStartupScript}/bin/start'';
    };
  };
}

