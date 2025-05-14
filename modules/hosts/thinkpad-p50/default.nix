{ inputs, cRoot, ... }:

{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    "${cRoot}/modules/configs"
    "${cRoot}/modules/users/rx"
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p50
  ];
}