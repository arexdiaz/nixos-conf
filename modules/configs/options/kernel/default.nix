{ lib, ... }:

{
  imports = [
    ./cachyos.nix
    ./options/iommu.nix
    ./options/scheds.nix
    ./zen-rdtsc.nix
  ];
}