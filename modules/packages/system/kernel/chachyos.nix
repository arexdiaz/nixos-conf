{ config, pkgs, ... }:

{
  # Bootloader configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true; };
    kernelPackages = pkgs.linuxPackages_cachyos; # https://github.com/CachyOS/linux-cachyos

    # Load OverlayFS kernel module (required for OverlayFS)
    kernelModules = [ "overlay" ];
  };

  # Scx scheduler config
  services.scx = {
    package = pkgs.scx_git.full;
    scheduler = "scx_bpfland";
    enable = true;
  };
}