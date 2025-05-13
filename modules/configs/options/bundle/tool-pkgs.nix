{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.bundle.tools.enable {
  environment.systemPackages = with pkgs; [
    burpsuite
    nmap
    remmina
    wireshark
    ghidra
  ];
}