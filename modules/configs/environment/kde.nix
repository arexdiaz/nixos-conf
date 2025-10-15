{ config, pkgs, inputs, lib, ... }:

# Make the entire KDE configuration conditional
lib.mkIf config.preconfs.system.desktop.environment.kde.enable {
  services = { # xserver.enable is now handled by the parent desktop-envs module
    desktopManager.plasma6.enable = true;
    displayManager = {
      sddm.enable = true;
      defaultSession = "plasma";
    };
  };

  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.krdc
    kdePackages.yakuake
    libnotify
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    elisa
    kate
  ];
}