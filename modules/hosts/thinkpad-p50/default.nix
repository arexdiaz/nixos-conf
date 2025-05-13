{ config, pkgs, lib, inputs, cRoot, ... }:

let
  modules = [
    "common.nix"
    "users/rx"
    "packages/fish-shell.nix"
    "packages/kernel/chachyos.nix"
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
  };

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

  # local packages
  desktop = {
    environment.kde.enable = true;
    pkgs = {
      common.enable = true;
      games.enable  = true;
      media.enable  = true;
      tools.enable  = true;
    };
  };
  
  vmTools = {
    virtualManager = {
      enable = true;
      libvirtdMembers = [ "rx" ];
      virtioWinISO.enable = true;
    };
    docker = {
      enable = true;
      users = [ "rx" ];
    };
  };
  
  system.stateVersion = "24.11";
}