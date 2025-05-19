{ config, lib, ... }:

let
  cfg = config.preconfs.pkgs.kernel.iommu;
in
{
  config = lib.mkIf cfg.enable {
    boot.kernelParams =
      (lib.optionals cfg.intel [ "intel_iommu=on" ]) ++
      (lib.optionals cfg.amd [ "amd_iommu=on" ]) ++
      (lib.optionals cfg.passthrough [ "iommu=pt" ]);

    boot.kernelModules = [
      "vfio"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio_virqfd"
    ];

    boot.initrd.kernelModules = [
      "vfio"
      "vfio_pci"
      "vfio_iommu_type1"
    ];

  };
}