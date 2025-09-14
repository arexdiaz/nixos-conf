{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.pkgs.media.enable {
  environment.systemPackages = with pkgs; [
    qbittorrent-enhanced
    spotify
    vlc
  ];

  services.plex = lib.mkIf config.preconfs.pkgs.media.plex.enable {
    enable = true;
    openFirewall = true;
    user = config.preconfs.pkgs.media.plex.user;
  };

  systemd.services.plex = lib.mkIf config.preconfs.pkgs.media.plex.enable {
    serviceConfig = {
      TimeoutStopSec = lib.mkForce config.preconfs.pkgs.media.plex.timeoutStopSec;
      KillMode = lib.mkForce "mixed";
      KillSignal = lib.mkForce "SIGTERM";
      FinalKillSignal = lib.mkForce "SIGKILL";
    };
  };
}