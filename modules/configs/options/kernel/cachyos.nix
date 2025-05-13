{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.chaotic.nixosModules.default
  ];

  config = lib.mkIf config.preconfs.pkgs.kernel.cachyos.enable {
    boot.kernelPackages = pkgs.linuxPackages_cachyos; # https://github.com/CachyOS/linux-cachyos

    # Scx scheduler config
    services.scx = {
      package = pkgs.scx_git.full;
      scheduler = "scx_bpfland";
      # This 'enable' is for the scx service itself,
      # it will only be configured if preconfs.kernel.cachyos.enable is true.
      enable = true;
    };
  };
}