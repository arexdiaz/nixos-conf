{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../packages/core-pkgs.nix
    ../../packages/desktop/shell/gnome.nix
    ../../packages/desktop/desktop-pkgs.nix
    ../../packages/fish-shell.nix
    ../../networking.nix
    ../../services.nix
    ../../system.nix
    ../../users/rx
  ];

  networking.hostName = "apple-m1";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}