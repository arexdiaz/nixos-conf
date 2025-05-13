{ config, pkgs, inputs, ... }:

{
  imports = [
    ./options
    ./networking.nix
    ./services.nix
    ./system.nix
    inputs.home-manager.nixosModules.default
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
