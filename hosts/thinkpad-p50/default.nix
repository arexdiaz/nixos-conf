{ config, pkgs, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../modules/networking.nix
      ../../modules/packages.nix
      ../../modules/services.nix
      ../../modules/system.nix
      ../../modules/users/rx
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p50
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "lvnpc";
}