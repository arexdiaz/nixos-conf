{ config, pkgs, lib, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../packages/core-pkgs.nix
      ../../packages/desktop/shell/kde.nix
      ../../packages/desktop/desktop-pkgs.nix
      ../../packages/desktop/entertainment-pkgs.nix
      ../../packages/desktop/hideo-pkgs.nix
      ../../packages/desktop/tools-pkgs.nix
      ../../packages/desktop/qemu.nix
      ../../packages/fish-shell.nix
      # ../../packages/system/kernel/chachyos.nix
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
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Available options: stable | beta
  };

  boot.blacklistedKernelModules = [ "nouveau" ];
  programs.nix-ld.enable = true;
}