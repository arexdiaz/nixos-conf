{ config, pkgs, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../modules/packages/core-pkgs.nix
      ../../modules/packages/desktop/desktop-pkgs.nix
      ../../modules/packages/desktop/entertainment-pkgs.nix
      ../../modules/packages/desktop/hideo-pkgs.nix
      ../../modules/packages/desktop/tools-pkgs.nix
      ../../modules/packages/fish-shell.nix
      ../../modules/networking.nix
      ../../modules/services.nix
      ../../modules/system.nix
      ../../modules/users/rx
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p50
  ];

  networking.hostName = "lvnpc";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable beta nvidia drivers
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
}