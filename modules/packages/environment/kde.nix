{ config, pkgs, inputs, lib, ... }:

# Make the entire KDE configuration conditional
lib.mkIf config.pkgs.desktop.environment.kde.enable {
  services = { # xserver.enable is now handled by the parent desktop-envs module
    desktopManager.plasma6.enable = true;
    displayManager = {
      sddm.enable = true;
      defaultSession = "plasma";
    };
  };

  environment.systemPackages = with pkgs; [
    kdePackages.kdeconnect-kde
    kdePackages.krdc
    kdePackages.yakuake
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    elisa
    kate
  ];
}