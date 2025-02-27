{ config, pkgs, inputs, ... }:

{
  imports = [
      ../../modules/networking.nix
      ../../modules/packages.nix
      ../../modules/services.nix
      ../../modules/system.nix
      ../../modules/users/rx
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p50
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the Nix flake support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "lvnpc";
}