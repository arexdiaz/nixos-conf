{ config, inputs, lib, ... }:
let
  confs = config.preconfs;
  qemu-patch = confs.pkgs.virtualisation.virtualManager.QemuPatch;
  ovmf-patch = confs.pkgs.virtualisation.virtualManager.OvmfPatch;
in
{
  imports = [
    ./networking.nix
    ./options
    ./services.nix
    ./system.nix
    inputs.home-manager.nixosModules.default
  ];

  nixpkgs.overlays =
    (lib.optionals qemu-patch.enable [(import ./options/overlays/qemu-custom.nix)]) ++
    (lib.optionals ovmf-patch.enable [(import ./options/overlays/ovmf-patch.nix)])
    ; # Add more by appending ++ to the last import

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
