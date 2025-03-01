{ config, pkgs, inputs, ... }:

{
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      moonlight-qt
      qbittorrent-enhanced
      spotify
      vlc
    ];
}