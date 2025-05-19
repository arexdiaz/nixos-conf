{ config, inputs, lib, ... }:
let
  confs = config.preconfs;
  qemu-patch = confs.pkgs.virtualisation.virtualManager.phantomQemuPatch;
  edk2-patch = confs.pkgs.virtualisation.virtualManager.phantomEdk2Patch;
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
    (lib.optionals qemu-patch.enable [(import ./options/overlays/qemu-custom.nix)]) ++
    (lib.optionals edk2-patch.enable [(import ./options/overlays/edk2-patch.nix)])
    ; # Add more by appending ++ to the last import

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
