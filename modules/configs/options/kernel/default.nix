{ lib, ... }:

{
  imports = [
    ./cachyos.nix
    ./patches/rdtsc.nix
    ./iommu.nix
  ];
}