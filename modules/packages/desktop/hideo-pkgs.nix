{ config, pkgs, inputs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
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