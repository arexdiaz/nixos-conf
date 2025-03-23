{ config, pkgs, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../packages/core-pkgs.nix
      ../../packages/desktop/desktop-pkgs.nix
      ../../packages/desktop/entertainment-pkgs.nix
      ../../packages/desktop/hideo-pkgs.nix
      ../../packages/desktop/tools-pkgs.nix
      ../../packages/fish-shell.nix
      ../../packages/development/qemu.nix
      ../../networking.nix
      ../../services.nix
      ../../system.nix
      ../../users/rx
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p50
  ];

  networking.hostName = "lvnpc";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable beta nvidia drivers
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  programs.nix-ld.enable = true;
}