{ config, inputs, lib, ... }:
let
  confs = config.preconfs;
  qemu-patch = confs.system.virtualization.virtualManager.QemuPatch;
  ovmf-patch = confs.system.virtualization.virtualManager.OvmfPatch;
in
{
  imports = [
    ./networking.nix
    ./options
    ./services.nix
    ./system.nix
    ./environment/kde.nix
    ./environment/gnome.nix
    ./core-pkgs.nix
    ./common-pkgs.nix
    ./emulators
    ./game-pkgs.nix
    ./kernel
    ./media-pkgs.nix
    ./tool-pkgs.nix
    ./shell/fish-shell.nix
    ./virtualization/docker.nix
    ./virtualization/virtman.nix
    ./virtualization/looking-glass.nix
    ./shell/aliases/vfio
    ./options
  ];

  nixpkgs.overlays =
    (lib.optionals qemu-patch.enable [(import ./overlays/qemu-custom.nix)]) ++
    (lib.optionals ovmf-patch.enable [(import ./overlays/ovmf-patch.nix)])
    ; # Add more by appending ++ to the last import

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
