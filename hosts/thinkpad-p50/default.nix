{ config, pkgs, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../modules/packages/core-pkgs.nix
      ../../modules/packages/desktop-pkgs.nix
      ../../modules/packages/entertainment-pkgs.nix
      ../../modules/packages/fish.nix
      ../../modules/packages/hideo-pkgs.nix
      ../../modules/packages/tools-pkgs.nix
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