{ config, pkgs, inputs, ... }:

{
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      qbittorrent-enhanced
      spotify
      vlc
    ];
}