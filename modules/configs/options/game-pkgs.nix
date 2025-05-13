{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.pkgs.games.enable {
  environment.systemPackages = with pkgs; [
    bolt-launcher
    moonlight-qt
    runelite
    parsec-bin
  ];

  programs = {
    steam.enable = true;
  };
}