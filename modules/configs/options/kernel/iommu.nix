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
  };
}