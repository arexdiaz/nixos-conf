{ config, pkgs, lib, ... }:

lib.mkIf config.desktop.pkgs.media.enable {
  environment.systemPackages = with pkgs; [
    qbittorrent-enhanced
    spotify
    vlc
  ];
}