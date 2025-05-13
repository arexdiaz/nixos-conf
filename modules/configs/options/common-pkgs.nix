{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.notion-app-electron.package.default
  ];
  
  config = lib.mkIf config.preconfs.pkgs.common.enable {
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
  };
}