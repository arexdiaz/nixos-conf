{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.pkgs.tools.enable {
  environment.systemPackages = with pkgs; [
    burpsuite
    devenv
    nmap
    wireshark
    ghidra
  ];
}