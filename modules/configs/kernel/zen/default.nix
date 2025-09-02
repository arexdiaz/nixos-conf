{ config, pkgs, lib, ... }:

let
  cfgZen = config.preconfs.system.kernel.zen;
  zenKernel = import ./package.nix { inherit pkgs lib; };
in
{
  config = lib.mkIf cfgZen.enable {
    boot =
      if cfgZen.patch.rdtsc.enable then {
        kernelPackages = zenKernel;
      } else {
        kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel.kernels.linux_zen;
      };
  };
}