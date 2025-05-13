{ config, pkgs, inputs, lib, ... }:

lib.mkIf config.pkgs.bundle.common.enable {
  environment.systemPackages = with pkgs; [
    alacritty
    onlyoffice-desktopeditors
    vscode
    notion-app-electron
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