{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.chaotic.nixosModules.default
  ];

  boot.kernelPackages = pkgs.linuxPackages_cachyos; # https://github.com/CachyOS/linux-cachyos

  # Scx scheduler config
  services.scx = {
    package = pkgs.scx_git.full;
    scheduler = "scx_bpfland";
    enable = true;
  };
}