{ config, pkgs, inputs, lib, ... }:

{
  imports = [ ./kde.nix ./gnome.nix ./common-pkgs.nix ./media-pkgs.nix ./tool-pkgs.nix ./game-pkgs.nix ];

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
    pkgs = {
      common = {
        enable = lib.mkEnableOption "Whether to enable common desktop packages.";
      };
      games = {
        enable = lib.mkEnableOption "Whether to enable game packages.";
      };
      media = {
        enable = lib.mkEnableOption "Whether to enable media packages.";
      };
      tools = {
        enable = lib.mkEnableOption "Whether to enable tool packages.";
      };
    };
  };

  config = {
    # Enable the X server if the corresponding option is set
    services.xserver.enable = config.desktop.environment.xserver.enable;
  };
}
