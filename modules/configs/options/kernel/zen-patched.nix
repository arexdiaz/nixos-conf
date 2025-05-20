{ config, pkgs, inputs, lib, ... }:

{
  config = lib.mkIf config.preconfs.pkgs.kernel.zen-patched.enable {
    boot.kernelPackages = let
      version = "6.14.6";
      suffix = "zen1";
    in pkgs.linuxPackagesFor (pkgs.linux_zen.override {
      inherit version suffix;
      modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
      src = pkgs.fetchFromGitHub {
        owner = "zen-kernel";
        repo = "zen-kernel";
        rev = "v${version}-${suffix}";
        sha256 = "sha256-NW+ezX0csXPiTBILEaAW1gue1oAJiK4IkjKpvxADPWM=";
      };
    });
    boot.kernelPatches = [
      {
        name = "vmx-rdtsc-patch";
        patch = pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/Scrut1ny/Hypervisor-Phantom/refs/heads/main/Hypervisor-Phantom/patches/Kernel/zen-kernel-6.14-latest-vmx.mypatch";
          sha256 = "sha256-VbbQDmKozlzUo55+QfZMq/ZcY2o1NgPcDf0fO4DzC2A=";
        };
      }
    ];
  };
}