{ config, pkgs, inputs, lib, ... }:

{
  imports = [ ./kde.nix ./gnome.nix ./common-pkgs.nix ];

  options.desktop = {
    environment = {
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
    commonPkgs = {
      enable = lib.mkEnableOption "Whether to enable common desktop packages.";
    };
  };

  config = {
    # Enable the X server if the corresponding option is set
    services.xserver.enable = config.desktop.environment.xserver.enable;
  };
}
