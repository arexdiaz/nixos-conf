{ config, pkgs, inputs, ... }:

{
  imports = [
    ./networking.nix
    ./packages/core-pkgs.nix
    ./packages/desktop-envs
    ./packages/emulators
    ./packages/virtualization
    ./services.nix
    ./system.nix
    inputs.home-manager.nixosModules.default
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
