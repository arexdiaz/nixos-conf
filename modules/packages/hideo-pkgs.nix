{ config, pkgs, inputs, ... }:

{
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