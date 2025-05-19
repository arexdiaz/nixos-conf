{ config, inputs, lib, ... }:
let
  confs = config.preconfs;
  qemu-patch = confs.pkgs.virtualisation.virtualManager.phantomQemuPatch;
in
{
  imports = [
    ./options
    ./networking.nix
    ./services.nix
    ./system.nix
    inputs.home-manager.nixosModules.default
  ];

  nixpkgs.overlays =
    (lib.optionals qemu-patch.enable [(import ./options/virtualization/qemu-custom.nix)])
    ; # Add more by appending ++ to the last import

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
