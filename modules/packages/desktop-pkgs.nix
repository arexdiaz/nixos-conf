{ config, pkgs, inputs, ... }:

{
  services = {
    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    kdePackages.kdeconnect-kde
    kdePackages.krdc
    kdePackages.yakuake
    onlyoffice-desktopeditors
    vscode
    inputs.notion-app-electron.packages.${pkgs.system}.default
  ];

  programs = {
    firefox.enable = true;

    htop = {
      enable = true;
      package = pkgs.htop;
      settings = {
        show_cpu_temperature = true;
        show_cpu_frequency = true;
      };
    };
  };
}