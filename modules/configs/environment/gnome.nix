{ config, pkgs, lib, inputs, ... }:

lib.mkIf config.preconfs.system.desktop.environment.gnome.enable {
  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ddcutil # required by brightess control
    gnomeExtensions.brightness-control-using-ddcutil
    gnomeExtensions.dash-to-dock
    gnomeExtensions.forge
    gnomeExtensions.logo-menu
    gnomeExtensions.open-bar
    gnomeExtensions.media-controls
  ];

  # required by brightess control
  users.extraGroups = {
    i2c = {};
  };
  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", MODE="0660", GROUP="i2c"
  '';

  environment.variables.NIXOS_OZONE_WL = "1";

  environment.gnome.excludePackages = with pkgs; [
    orca
    evince
    # file-roller
    geary
    gnome-disk-utility
    # seahorse
    # sushi
    # sysprof
    #
    # gnome-shell-extensions
    #
    # adwaita-icon-theme
    # nixos-background-info
    gnome-backgrounds
    # gnome-bluetooth
    # gnome-color-manager
    # gnome-control-center
    # gnome-shell-extensions
    gnome-tour # GNOME Shell detects the .desktop file on first log-in.
    gnome-user-docs
    # glib # for gsettings program
    # gnome-menus
    # gtk3.out # for gtk-launch program
    # xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
    # xdg-user-dirs-gtk # Used to create the default bookmarks
    #
    baobab
    epiphany
    gnome-text-editor
    gnome-calculator
    gnome-calendar
    gnome-characters
    # gnome-clocks
    gnome-console
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    # gnome-system-monitor
    gnome-weather
    # loupe
    # nautilus
    gnome-connections
    simple-scan
    snapshot
    totem
    yelp
    gnome-software
  ];
}