{ config, pkgs, inputs, ... }:

let
  pcsx2wrap = pkgs.callPackage ./pcsx2wrap {};
in
{
  environment.systemPackages = with pkgs; [
    gamescope
    lutris
    mangohud
    mangojuice
    protontricks
    wine
    winetricks
    pcsx2wrap
  ];
}
