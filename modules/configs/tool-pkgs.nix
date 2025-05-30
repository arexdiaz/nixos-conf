{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.pkgs.tools.enable {
  environment.systemPackages = with pkgs; [
    burpsuite
    nmap
    remmina
    wireshark
    ghidra
  ];
}