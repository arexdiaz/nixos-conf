{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./kde.nix
    ./gnome.nix
    ./pkgs/common-pkgs.nix
    ./pkgs/media-pkgs.nix
    ./pkgs/tool-pkgs.nix
    ./pkgs/game-pkgs.nix
    ./pkgs/emulators
  ];

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
      emulators = {
        enable = lib.mkEnableOption "Whether to enable emulator packages and configurations.";
      };
    };
  };

  config = {
    # Enable the X server if the corresponding option is set
    services.xserver.enable = config.desktop.environment.xserver.enable;
  };
}
