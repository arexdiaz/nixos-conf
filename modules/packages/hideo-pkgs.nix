{ config, pkgs, inputs, ... }:

{
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        bolt-launcher
        runelite
    ];

    programs = {
      steam.enable = true;
    };
}