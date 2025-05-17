{ lib, ... }:

{
  imports = [
    ./cachyos.nix
    ./patches/rdtsc.nix
    # You can add other kernel-specific option modules here in the future
    # e.g., ./mainline.nix, ./zen.nix
  ];
}