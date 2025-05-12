# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./networking.nix
      ./services.nix
      ./system.nix
      inputs.home-manager.nixosModules.default
      inputs.chaotic.nixosModules.default
      inputs.nix-flatpak.nixosModules.nix-flatpak
    ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
