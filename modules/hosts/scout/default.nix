{ config, pkgs, lib, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../packages/core-pkgs.nix
      ../../packages/desktop/shell/kde.nix
      ../../packages/desktop/docker.nix
      ../../packages/desktop/desktop-pkgs.nix
      ../../packages/desktop/entertainment-pkgs.nix
      ../../packages/desktop/hideo-pkgs.nix
      ../../packages/desktop/tools-pkgs.nix
      ../../packages/desktop/qemu.nix
      ../../packages/fish-shell.nix
      ../../packages/system/kernel/chachyos.nix
      ../../networking.nix
      ../../services.nix
      ../../system.nix
      ../../users/rx
  ];

  networking.hostName = "scout";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs;
[nvidia-vaapi-driver];
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  # Enable beta nvidia drivers
  # hardware.nvidia = {
    # open = true;
    # package = config.boot.kernelPackages.nvidiaPackages.beta; # Available options: stable | beta
  # };

  boot.blacklistedKernelModules = [ "nouveau" ];
  programs.nix-ld.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
  # services.thermald ={
  #   enable = true;
  # };
}
