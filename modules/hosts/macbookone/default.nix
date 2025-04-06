{ config, pkgs, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../packages/core-pkgs.nix
      ../../packages/desktop/desktop-pkgs.nix
      ../../packages/desktop/environments/gnome.nix
      ../../packages/fish-shell.nix
      ../../networking.nix
      ../../services.nix
      ../../system.nix
      ../../users/rx
  ];

  networking.hostName = "haiiii";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}