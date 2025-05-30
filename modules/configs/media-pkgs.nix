{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.pkgs.media.enable {
  environment.systemPackages = with pkgs; [
    qbittorrent-enhanced
    spotify
    vlc
  ];
}