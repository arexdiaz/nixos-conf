{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    burpsuite
    nmap
    remmina
    wireshark
    ghidra
  ];
}