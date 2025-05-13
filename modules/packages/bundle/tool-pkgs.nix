{ config, pkgs, lib, ... }:

lib.mkIf config.pkgs.bundle.tools.enable {
  environment.systemPackages = with pkgs; [
    burpsuite
    nmap
    remmina
    wireshark
    ghidra
  ];
}