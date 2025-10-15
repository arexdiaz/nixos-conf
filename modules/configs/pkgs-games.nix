{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.pkgs.games.enable {
  environment.systemPackages = with pkgs; [
    bolt-launcher
    moonlight-qt
    runelite
    parsec-bin
  ];

  nixpkgs.overlays = [
    (final: prev: {
      bolt-launcher = prev.bolt-launcher.override {
        jdk17 = final.openjdk11;
      };
    })
  ];

  programs = {
    steam.enable = true;
  };
}
