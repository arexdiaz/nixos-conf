{ config, pkgs, inputs, ... }:

{
  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kdePackages.kdeconnect-kde
    kdePackages.krdc
    kdePackages.yakuake
  ];
}