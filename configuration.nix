# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/nixos/nh.nix
      ./modules/nixos/vintagestory-server.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
   time.timeZone = "America/Chicago";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  
  # Enable Hyprland
  services.displayManager.gdm.wayland = true;
  services.xserver.videoDrivers = ["nvidia"]; # Set video drivers for gaming, also enables them for wayland
 
  programs.hyprland = {
    enable = true;
     #package = inputs.hyprland.packages."${pkgs.system}".hyprland; # Set this in flake, useful for getting hyprland plugins in home-manager
    xwayland.enable = true;
  };

 #programs.niri = {
 #  enable = true;
 #};

  environment.sessionVariables = {
    #WLR_NO_HARDWARE_CURSORS = "1"; # If cursor becomes invisible in wayland
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME="qt5ct";
    NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = 
      "/home/graysonr/.steam/root/compatibilitytools.d";
    DISPLAY = ":1";
    WAYLAND_DISPLAY = "wayland-1";
  };

  hardware.graphics = {
    enable = true; 
    enable32Bit = true;
    extraPackages = with pkgs; [ libGL egl-wayland nvidia-vaapi-driver ];
  };
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };

 #hardware.opengl = {
 #  enable = true;
 #  extraPackages = [ pkgs.nvidia-vaapi-driver ];
 #};

  # Configure keymap in X11
   services.xserver.xkb = {
     layout = "us";
     variant = "";
   };


  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  security.rtkit.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true; # Needed for JACK applications
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users = {
    graysonr = {
     isNormalUser = true;
     description = "Grayson Robbins";
     extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       # thunderbird
     ];
    };

   };

  # Install firefox
  programs.firefox.enable = true;

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  boot = {
    kernelModules = [
      "nvidia"
      "nvidia-drm"
      "nvidia-modeset"
    ];
    kernelParams = [ "nvidia-drm.modeset=1" ];
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    home-manager

    (waybar.overrideAttrs (oldAttrs: { # Use waybar for hyprland
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ]; # Overwrite some attributes to make this work with Hyprland, might be unnecessary.
     })
    )

    mako # pure wayland notification daemon
    libnotify # mako relies on this
    protonup-ng
    kitty # Hyprland default terminal

    swww # Wallpaper manager
    networkmanagerapplet
    wofi # app launcher, based on GTK
    bottles
    ags # Aylur's GTK Shell, for making wayland widgets
    bun # Used to make AGS projects in TS
  ];

  environment.variables.EDITOR = "nvim"; # Set neovim as the default editor for the system
  environment.shellAliases = {
    nvim = "nix run ~/nixOS/";
    vi = "nix run ~/nixOS/";
    vim = "nix run ~/nixOS/";

  };
  xdg.portal.enable = true; # Enable desktop portal
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # Using GTK from Vimjoyer's Hyprland tutorial

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  
  programs.gamemode.enable = true;

  # Allow insecure dotnet runtime so that Vintage Story will work
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-wrapped-7.0.20"
    "dotnet-runtime-7.0.20"
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.

  # NEED 42420 OPEN FOR VINTAGE STORY!!!
  networking.firewall.allowedTCPPorts = [ 42420 ];
  networking.firewall.allowedUDPPorts = [ 42420 ];


  services.vintagestory-server.enable = true;

  services.vintagestory-server.dataDir = "/var/lib/vintagestory";

  services.vintagestory-server.configJson = ''
    {
      "serverName": "My NixOS VS Server",
      "maxPlayers": 12,
      "serverPort": 42420,
      "maxChunkGenerateDistance": 7,
      "maxChunkSafeRange": 5,
      "saveInterval": 300
    }
  '';

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

