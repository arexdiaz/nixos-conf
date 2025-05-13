{ config, pkgs, inputs, ... }:

{
  imports = [
    ./configs/options
    ./configs/networking.nix
    ./configs/services.nix
    ./configs/system.nix
    inputs.home-manager.nixosModules.default
    inputs.notion-app-electron.package.default
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
