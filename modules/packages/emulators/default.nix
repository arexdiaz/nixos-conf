{ config, pkgs, inputs, lib, ... }:

let
  pcsx2wrap = pkgs.callPackage ./pcsx2wrap {};
in
{
  options.emulators = {
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

  config = {
    environment.systemPackages = with pkgs;
    lib.optionals config.emulators.wine.enable [
      wine
      winetricks
    ] ++ lib.optionals config.emulators.gaming.pcsx2.enable [
      pcsx2wrap
    ] ++ lib.optionals config.emulators.gaming.lutris.enable [
      gamescope
      lutris
      mangohud
      mangojuice
    ];
  };
}
