{ config, pkgs, inputs, lib, ... }:

let
  # Path to pcsx2wrap is relative to this file's location.
  # From /etc/nixos/modules/packages/desktop/emulators/default.nix
  # to /etc/nixos/modules/packages/pcsx2wrap/default.nix
  pcsx2wrap = pkgs.callPackage ./pcsx2wrap {};
in
{
  # Options are defined unconditionally at the module level.
  options.pkgs.bundle.emulators = {
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
  config = lib.mkIf config.pkgs.bundle.emulators.enable {
    environment.systemPackages = with pkgs;
      lib.optionals config.pkgs.bundle.emulators.wine.enable [
        wine
        winetricks
      ] ++ lib.optionals config.pkgs.bundle.emulators.gaming.pcsx2.enable [
        pcsx2wrap
      ] ++ lib.optionals config.pkgs.bundle.emulators.gaming.lutris.enable [
        gamescope
        lutris
        mangohud
        mangojuice
      ];
  };
}
