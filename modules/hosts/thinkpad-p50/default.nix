{ config, pkgs, lib, inputs, cRoot, ... }:

let
  modules = [
    "commons.nix"
    "users/rx"
    "packages/core-pkgs.nix"
    "packages/desktop/shell/kde.nix"
    "packages/desktop/docker.nix"
    "packages/desktop/desktop-pkgs.nix"
    "packages/desktop/entertainment-pkgs.nix"
    "packages/desktop/hideo-pkgs.nix"
    "packages/desktop/tools-pkgs.nix"
    "packages/desktop/qemu.nix"
    "packages/fish-shell.nix"
    "packages/system/kernel/chachyos.nix"
  ];

  importModules = lib.map (path: "${cRoot}/modules/${path}") modules;
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p50
  ] ++ importModules;

  networking = {
    hostName = "lvnpc";
    firewall.allowedTCPPorts = [ 3000 ];
  }

  # Enable beta nvidia drivers
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta; # Available options: stable | beta
  };

  boot.blacklistedKernelModules = [ "nouveau" ];
  programs.nix-ld.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
  services.thermald ={
    enable = true;
  };
  
  system.stateVersion = "24.11";
}