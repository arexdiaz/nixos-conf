{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.bundle.media.enable {
  environment.systemPackages = with pkgs; [
    qbittorrent-enhanced
    spotify
    vlc
  ];
}