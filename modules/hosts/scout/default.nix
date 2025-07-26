{ config, pkgs, lib, inputs, cRoot, ... }:

{
  imports = [
    "${cRoot}/modules/configs"
    "${cRoot}/modules/users/rx"
    ./configuration.nix
    ./hardware-configuration.nix
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];
}
