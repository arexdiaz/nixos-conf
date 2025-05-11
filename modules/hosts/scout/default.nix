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
      # ../../packages/desktop/qemu.nix
      ../../packages/fish-shell.nix
      ../../packages/system/kernel/chachyos.nix
      ../../packages/desktop/wine.nix
      ../../networking.nix
      ../../services.nix
      ../../system.nix
      ../../users/rx
  ];

  networking.hostName = "scout";
  nixpkgs.config.allowUnfree = true;

  boot.blacklistedKernelModules = [ "nouveau" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
    graphics = {
      enable = true;
      extraPackages = with pkgs; [nvidia-vaapi-driver];
    };
  };

  programs.nix-ld.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  services.plex = {
    enable = true;
    openFirewall = true;
    user="rx";
  };

  fileSystems = {
    "/mnt/Stuff" = {
      device = "/dev/disk/by-uuid/d4a092ab-ae4a-43b5-821b-3aa104a572a1";
      fsType = "ext4";
      options = [ "users" "nofail" "exec" ];
    };
    "/mnt/Stuff2" = {
      device = "/dev/disk/by-uuid/CA33-738B";
      fsType = "vfat";
      options = [ "users" "nofail" "exec" ];
    };
  };
  
  # services.thermald ={
  #   enable = true;
  # };
}
