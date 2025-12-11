{ config, pkgs, inputs, lib, ... }:

{
  # Options are defined unconditionally at the module level.
  options.preconfs.pkgs.emulators = {
    wine = {
      enable = lib.mkEnableOption "Whether to install Wine and Winetricks compatibility layer.";
    };
    gaming = {
      pcsx2 = {
        enable = lib.mkEnableOption "Whether to install PCSX2 emulator.";
      };
      lutris = {
        enable = lib.mkEnableOption "Whether to install Lutris and related gaming utilities.";
      };
    };
  };

  # The configuration (effect of the options) is conditional.
  config = lib.mkIf config.preconfs.pkgs.emulators.enable {
    environment.systemPackages = with pkgs;
      lib.optionals config.preconfs.pkgs.emulators.wine.enable [
        wineWowPackages.staging
        winetricks
      ] ++ lib.optionals config.preconfs.pkgs.emulators.gaming.pcsx2.enable [
        pcsx2
      ] ++ lib.optionals config.preconfs.pkgs.emulators.gaming.lutris.enable [
        lutris
        gamescope
        mangohud
        mangojuice
      ];
  };
}
