{ lib, ... }:

{
  imports = [
    ./cachyos.nix
    ./iommu.nix
    ./scheds.nix
    ./zen
  ];
}