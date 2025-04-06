{ config, pkgs, lib, inputs, ... }:
{
  services.xserver = {
    enable = true;
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
  ];

  # required by brightess control
  users.extraGroups = {
    i2c = {};
  };

  # required by brightess control
  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", MODE="0660", GROUP="i2c"
  '';

  environment.variables.NIXOS_OZONE_WL = "1"; # Fixes Firefox/Chromium on Wayland
  nixpkgs.overlays = [
    # GNOME 47: triple-buffering-v4-47
    (final: prev: {
      mutter = prev.mutter.overrideAttrs (oldAttrs: {
        src = final.fetchFromGitLab {
          domain = "gitlab.gnome.org";
          owner = "vanvugt";
          repo = "mutter";
          rev = "triple-buffering-v4-47";
          hash = "sha256-6n5HSbocU8QDwuhBvhRuvkUE4NflUiUKE0QQ5DJEzwI=";
        };
        preConfigure = let
          gvdb = final.fetchFromGitLab {
            domain = "gitlab.gnome.org";
            owner = "GNOME";
            repo = "gvdb";
            rev = "2b42fc75f09dbe1cd1057580b5782b08f2dcb400";
            hash = "sha256-CIdEwRbtxWCwgTb5HYHrixXi+G+qeE1APRaUeka3NWk=";
          };
        in ''
          cp -a "${gvdb}" ./subprojects/gvdb
        '';
      });
    })
  ];

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