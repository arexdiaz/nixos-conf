{ config, pkgs, inputs, ... }:

{
  services = {
    xserver.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager = {
      sddm.enable = true;
      defaultSession = "plasma";
    };
  };

  environment.systemPackages = with pkgs; [
    kdePackages.kdeconnect-kde
    kdePackages.krdc
  ];
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    elisa
  ];
}