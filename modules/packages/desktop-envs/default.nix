{ config, pkgs, inputs, lib, ... }:

{
  imports = [ ./kde.nix ./gnome.nix ];

  options.desktopEnvs = {
    kde = {
      enable = lib.mkEnableOption "Whether to enable and configure the KDE Plasma desktop environment.";
    };
    gnome = {
      enable = lib.mkEnableOption "Whether to enable and configure the GNOME desktop environment.";
    };
    xserver = {
      enable = lib.mkEnableOption "Whether to enable the X server (required for graphical desktop environments).";
    };
  };

  config = {
    # Enable the X server if the corresponding option is set
    services.xserver.enable = config.desktopEnvs.xserver.enable;
  };
}
