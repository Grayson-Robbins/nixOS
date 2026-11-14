# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix

      # Desktop-specific self-hosted configuration
      ./selfhost.nix
      ./infrastructure.nix

      # Shared system modules
      ../../modules/nixos/nh.nix
      ../../modules/gaming/gaming.nix
    ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.kernelModules = [ "amdgpu" ];

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

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  
  # Enable Hyprland
  #services.displayManager.gdm.wayland = true;
  services.xserver.videoDrivers = [ "amdgpu" ]; # Set video drivers for gaming, also enables them for wayland
 
  #programs.hyprland = {
  #  enable = true;
  #  xwayland.enable = true;
  #};

  environment.sessionVariables = {
    #WLR_NO_HARDWARE_CURSORS = "1"; # If cursor becomes invisible in wayland
    QT_QPA_PLATFORMTHEME="qt5ct";
    NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
    #STEAM_EXTRA_COMPAT_TOOLS_PATHS = 
    #"/home/graysonr/.steam/root/compatibilitytools.d";
  };

  hardware.graphics = {
    enable = true; 
    enable32Bit = true;
    extraPackages = with pkgs; [ 
      #libGL 
      #egl-wayland 
      rocmPackages.clr.icd 
    ];
  };

  #boot.kernel.sysctl = {
  #  "net.ipv4.conf.all.rp_filter" = 0;
  #  "net.ipv4.conf.default.rp_filter" = 0;
  #  "net.ipv4.conf.enp3s0.rp_filter" = 0;
  #  "net.ipv4.ip_forward" = 1;  # Enable IP forwarding
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
  };


  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users = {
    graysonr = {
     isNormalUser = true;
     description = "Grayson Robbins";
     extraGroups = [ 
        "networkmanager" 
        "wheel" # Enable ‘sudo’ for the user. 
        "adbusers" # Enable ADB operations for this user (ALVR-related)
        "input" # Provide access to inputs for Waybar
    ]; 
     packages = with pkgs; [
       # thunderbird
     ];
    };

    kaylar = {
     isNormalUser = true;
     description = "Kayla Robbins";
     packages = with pkgs; [
       # thunderbird
     ];
    };
   };


  gaming = {
    enable = true;
    vr.enable = false;
    vintagestory.enable = false;

    # Option to enable dedicated server
    vintagestory-server.enable = false; 
  };
  


  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  boot = {
    kernelModules = [
      "amdgpu"
      "tun"
      "nft_chain_nat"
    ];
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
    clinfo # To verify that OpenCL is correctly setup
    ethtool

    (waybar.overrideAttrs (oldAttrs: { # Use waybar for hyprland
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ]; # Overwrite some attributes to make this work with Hyprland, might be unnecessary.
     })
    )

    mako # pure wayland notification daemon
    libnotify # mako relies on this
    kitty # Hyprland default terminal

    awww # Wallpaper manager
    networkmanagerapplet
    wofi # app launcher, based on GTK
    bottles
    bun # Used to make AGS projects in TS

    proton-pass

    xwayland-satellite # For running Steam in Niri

    (aichat.overrideAttrs (old: {
      nativeBuildInputs = 
        (old.nativeBuildInputs or [])
        ++ [ pkg-config ];
      buildInputs = 
        (old.buildInputs or [])
        ++ [ oniguruma ];
    }))
  ];

  environment.variables.EDITOR = "nvim"; # Set neovim as the default editor for the system
  environment.shellAliases = {
    nvim = "nix run ~/nixOS/";
    vi = "nix run ~/nixOS/";
    vim = "nix run ~/nixOS/";

  };
  xdg.portal.enable = true; # Enable desktop portal

  programs.niri.enable = true;
  home-manager.backupFileExtension = "backup";

  #services.ollama = {
  #  enable = true;
  #  package = pkgs.ollama-vulkan;
  #  host = "0.0.0.0";
  #};

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

