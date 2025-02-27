{ config, pkgs, inputs, ... }:

{
  imports =
    [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p50
    ];

  networking.hostName = "lvnpc";
}