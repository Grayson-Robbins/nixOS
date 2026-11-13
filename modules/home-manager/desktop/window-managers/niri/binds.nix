{ pkgs, ... }:

{
  programs.niri.settings.binds = {
    # Applications
    "Mod+Q".action.spawn = "${pkgs.kitty}/bin/kitty";
    "Mod+D".action.spawn = "${pkgs.fuzzel}/bin/fuzzel";

    "Mod+Space".action.spawn = [
      "${pkgs.wofi}/bin/wofi"
      "--show"
      "drun"
      "--allow-images"
    ];

    # Window management
    "Mod+C".action.close-window = [ ];
    "Mod+O".action.show-hotkey-overlay = [ ];
    "Mod+Tab".action.toggle-overview = [ ];

    # Quit Niri
    "Mod+Shift+E".action.quit = [ ];

    # Focus navigation (Vim)
    "Mod+H".action.focus-column-left = [ ];
    "Mod+J".action.focus-window-down = [ ];
    "Mod+K".action.focus-window-up = [ ];
    "Mod+L".action.focus-column-right = [ ];

    # Focus navigation (Arrow keys)
    "Mod+Left".action.focus-column-left = [ ];
    "Mod+Down".action.focus-window-down = [ ];
    "Mod+Up".action.focus-window-up = [ ];
    "Mod+Right".action.focus-column-right = [ ];

    # Move columns/windows
    "Mod+Ctrl+H".action.move-column-left = [ ];
    "Mod+Ctrl+J".action.move-window-down = [ ];
    "Mod+Ctrl+K".action.move-window-up = [ ];
    "Mod+Ctrl+L".action.move-column-right = [ ];

    "Mod+Ctrl+Left".action.move-column-left = [ ];
    "Mod+Ctrl+Down".action.move-window-down = [ ];
    "Mod+Ctrl+Up".action.move-window-up = [ ];
    "Mod+Ctrl+Right".action.move-column-right = [ ];

    # Monitor navigation
    "Mod+Shift+H".action.focus-monitor-left = [ ];
    "Mod+Shift+J".action.focus-monitor-down = [ ];
    "Mod+Shift+K".action.focus-monitor-up = [ ];
    "Mod+Shift+L".action.focus-monitor-right = [ ];

    "Mod+Shift+Left".action.focus-monitor-left = [ ];
    "Mod+Shift+Down".action.focus-monitor-down = [ ];
    "Mod+Shift+Up".action.focus-monitor-up = [ ];
    "Mod+Shift+Right".action.focus-monitor-right = [ ];

    # Move columns between monitors
    "Mod+Ctrl+Shift+H".action.move-column-to-monitor-left = [ ];
    "Mod+Ctrl+Shift+J".action.move-column-to-monitor-down = [ ];
    "Mod+Ctrl+Shift+K".action.move-column-to-monitor-up = [ ];
    "Mod+Ctrl+Shift+L".action.move-column-to-monitor-right = [ ];

    "Mod+Ctrl+Shift+Left".action.move-column-to-monitor-left = [ ];
    "Mod+Ctrl+Shift+Down".action.move-column-to-monitor-down = [ ];
    "Mod+Ctrl+Shift+Up".action.move-column-to-monitor-up = [ ];
    "Mod+Ctrl+Shift+Right".action.move-column-to-monitor-right = [ ];

    # Workspace navigation
    "Mod+1".action.focus-workspace = "desktop";
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+G".action.focus-workspace = "games";

    # Move windows to workspaces
    "Mod+Shift+1".action.move-window-to-workspace = "desktop";
    "Mod+Shift+2".action.move-window-to-workspace = 2;
    "Mod+Shift+3".action.move-window-to-workspace = 3;
    "Mod+Shift+4".action.move-window-to-workspace = 4;
    "Mod+Shift+G".action.move-window-to-workspace = "games";

    # Switch workspaces
    "Mod+I".action.focus-workspace-up = [ ];
    "Mod+U".action.focus-workspace-down = [ ];

    # Move columns between workspaces
    "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];
    "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];

    # Move entire workspaces
    "Mod+Shift+I".action.move-workspace-up = [ ];
    "Mod+Shift+U".action.move-workspace-down = [ ];

    # Consume / expel windows
    "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
    "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

    # Column sizing
    "Mod+R".action.switch-preset-column-width = [ ];
    "Mod+Shift+R".action.switch-preset-column-width-back = [ ];
    "Mod+F".action.maximize-column = [ ];
    "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];

    # Fullscreen and maximize
    "Mod+M".action.maximize-window-to-edges = [ ];
    "Mod+Shift+F".action.fullscreen-window = [ ];

    # Fine-grained sizing
    "Mod+Minus".action.set-column-width = "-10%";
    "Mod+Equal".action.set-column-width = "+10%";
    "Mod+Shift+Minus".action.set-window-height = "-10%";
    "Mod+Shift+Equal".action.set-window-height = "+10%";

    # Window height presets
    "Mod+Ctrl+R".action.reset-window-height = [ ];
    "Mod+Ctrl+Shift+R".action.switch-preset-window-height = [ ];

    # Floating / tiling
    "Mod+V".action.toggle-window-floating = [ ];
    "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

    # Tabbed columns
    "Mod+W".action.toggle-column-tabbed-display = [ ];
  };
}
