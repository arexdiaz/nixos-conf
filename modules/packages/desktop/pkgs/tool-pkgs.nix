{ config, pkgs, lib, ... }:

lib.mkIf config.desktop.pkgs.tools.enable {
  environment.systemPackages = with pkgs; [
    burpsuite
    nmap
    remmina
    wireshark
    ghidra
  ];
}