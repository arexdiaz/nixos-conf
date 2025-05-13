{ config, pkgs, lib, ... }:

lib.mkIf config.pkgs.bundle.media.enable {
  environment.systemPackages = with pkgs; [
    qbittorrent-enhanced
    spotify
    vlc
  ];
}