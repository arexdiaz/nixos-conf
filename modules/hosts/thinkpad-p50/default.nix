{ config, pkgs, lib, inputs, cRoot, ... }:

let
  modules = [
    "configs"
    "users/rx"
  ];

  importModules = lib.map (path: "${cRoot}/modules/${path}") modules;
in
{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p50
  ] ++ importModules;
  
}