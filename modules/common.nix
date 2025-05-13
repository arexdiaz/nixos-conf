{ config, pkgs, inputs, ... }:

{
  imports = [
    ./packages
    ./networking.nix
    ./services.nix
    ./system.nix
    inputs.home-manager.nixosModules.default
    inputs.notion-app-electron.package.default
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
