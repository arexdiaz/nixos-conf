{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.chaotic.nixosModules.default
  ];

  config = lib.mkIf config.preconfs.system.kernel.cachyos.enable {
    boot.kernelPackages = pkgs.linuxPackages_cachyos; # https://github.com/CachyOS/linux-cachyos
  };
}