{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.pkgs.kernel.patches.rdtsc.enable {
  boot.kernelPatches = [
    {
      name = "vmx-rdtsc-patch";

      patch = pkgs.fetchpatch {
        url = "https://raw.githubusercontent.com/Scrut1ny/Hypervisor-Phantom/refs/heads/main/Hypervisor-Phantom/patches/Kernel/zen-kernel-6.14-latest-vmx.mypatch";
        sha256 = "sha256-VbbQDmKozlzUo55+QfZMq/ZcY2o1NgPcDf0fO4DzC2A=";
      };
    }
  ];
}