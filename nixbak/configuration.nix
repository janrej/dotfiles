
{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/master.tar.gz;
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
      ./home.nix
  ];


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";

  # Enable networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  #networking.nameservers = [ "94.140.14.14" "94.140.15.15" ];

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "hyprland-uwsm";
  programs.hyprland.enable = true;
  programs.uwsm.enable = true;
  programs.hyprland.withUWSM = true;
  # services.xserver.enable = true;
  programs.hyprland.xwayland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;

  # Virtualisation

  networking.firewall.interfaces.virbr0.allowedTCPPorts = [ 53 ];
  networking.firewall.interfaces.virbr0.allowedUDPPorts = [ 53 67 ];

  boot.extraModprobeConfig = "options kvm_intel nested=1";

  services.dnsmasq.enable = true;
  services.dnsmasq.settings = {
    bind-interfaces = true;
  };
  
  programs.virt-manager.enable = true;
  
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [  ];
        };
      };
    };
    spiceUSBRedirection.enable = true;

  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jr = {
    isNormalUser = true;
    description = "JR";
    extraGroups = [ "libvirtd" "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    })
  '';  

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jr";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Optionally, set the environment variable

  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
      # gamescopeSession.enable = true;
    };
    gamemode.enable = true;
    
  };
  hardware.steam-hardware.enable = true;

  fonts.packages = [ pkgs.nerd-fonts.fira-code];

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [

    # Tools
    conky
    dig
    kdePackages.dolphin
    doublecmd
    exfat
    fastfetch
    file-roller
    git
    home-manager
    htop
    isoimagewriter
    kitty
    mc
    ntfs3g
    p7zip
    pavucontrol
    putty
    rpi-imager
    starship
    trezord
    trezor-suite
    trezor-udev-rules
    usbutils
    vscodium
    # xarchiver

    # Gaming 
    protonup-qt

    # Media
    aria2
    # libdrm
    # libva
    # libva1
    libva-utils
    # libva-vdpau-driver
    lux
    media-downloader
    svtplay-dl
    video-downloader
    vlc
    you-get
    yt-dlp

    # Web
    brave
    mullvad-browser

    # Hypr
    hyprlandPlugins.xtra-dispatchers
    hyprlang
    hyprnotify
    hyprpaper
    hyprpolkitagent
    hyprprop
    hyprutils
    syspower
    waytrogen
    wofi

  ];

  system.stateVersion = "25.11"; # Did you read the comment?

}