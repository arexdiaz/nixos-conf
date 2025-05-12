{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    qbittorrent-enhanced
    spotify
    vlc
  ];
}