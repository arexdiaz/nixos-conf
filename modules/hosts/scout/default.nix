{ config, pkgs, lib, inputs, cRoot, ... }:

let
  modules = [
    "common.nix"
    "users/rx"
    "fish-shell.nix"
    "kernel/chachyos.nix"
  ];

  # Prepend the common base path to each module file path
  importModules = lib.map (path: "${cRoot}/modules/${path}") modules;
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.nix-flatpak.nixosModules.nix-flatpak # will be moved later on
  ] ++ importModules;

  networking.hostName = "scout";
  nixpkgs.config.allowUnfree = true;

  boot.blacklistedKernelModules = [ "nouveau" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      open    = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
    graphics = {
      enable        = true;
      extraPackages = with pkgs; [nvidia-vaapi-driver];
    };
  };

  # local packages
  pkgs = {
    desktop.environment.kde.enable = true;
    bundle = {
      core.enable   = true;
      common.enable = true;
      games.enable  = true;
      media.enable  = true;
      tools.enable  = true;
      emulators = {
        enable      = true;
        wine.enable = true;
        gaming = {
          lutris.enable = true;
          pcsx2.enable  = true;
        };
      };
    };
  };

  programs.nix-ld.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  services.plex = {
    enable        = true;
    openFirewall  = true;
    user          = "rx";
  };

  fileSystems = {
    "/mnt/Stuff" = {
      device  = "/dev/disk/by-uuid/d4a092ab-ae4a-43b5-821b-3aa104a572a1";
      fsType  = "ext4";
      options = [ "users" "nofail" "exec" ];
    };
    "/mnt/Stuff2" = {
      device  = "/dev/disk/by-uuid/CA33-738B";
      fsType  = "vfat";
      options = [ "users" "nofail" "exec" ];
    };
  };
  
  # services.thermald ={
  #   enable = true;
  # };

  system.stateVersion = "24.11";
}
