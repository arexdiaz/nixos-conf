{ config, pkgs, lib, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../packages/core-pkgs.nix
      ../../packages/desktop/shell/gnome.nix
      ../../packages/desktop/desktop-pkgs.nix
      ../../packages/desktop/entertainment-pkgs.nix
      ../../packages/desktop/hideo-pkgs.nix
      ../../packages/desktop/tools-pkgs.nix
      ../../packages/development/qemu.nix
      ../../packages/fish-shell.nix
      ../../packages/system/kernel/chachyos.nix
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
    package = config.boot.kernelPackages.nvidiaPackages.beta; # Available options: stable | beta
  };

  boot.blacklistedKernelModules = [ "nouveau" ];
  programs.nix-ld.enable = true;

  # Modify systemd-suspend configuration to fix issue 
  # Not sure if this is a gnome only issue but just in case
  # Tired of troubleshooting issue on linux
  systemd.services."systemd-suspend" = lib.mkIf config.services.xserver.desktopManager.gnome.enable {
    serviceConfig = {
      Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";
    };
  };
}