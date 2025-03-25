{ config, pkgs, inputs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
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