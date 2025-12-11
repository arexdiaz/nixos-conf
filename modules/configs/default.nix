{ config, inputs, lib, ... }:
let
  confs = config.preconfs;
  qemu-patch = confs.system.virtualization.virtualManager.QemuPatch;
  ovmf-patch = confs.system.virtualization.virtualManager.OvmfPatch;
in
{
  imports = [
    ./environment/kde.nix
    ./environment/gnome.nix
    ./emulators
    ./kernel
    ./networking.nix
    ./options
    ./pkgs-common.nix
    ./pkgs-core.nix
    ./pkgs-games.nix
    ./pkgs-media.nix
    ./pkgs-tools.nix
    ./shell/fish-shell.nix
    ./shell/zsh-shell.nix
    ./system.nix
    ./services.nix
    ./virtualization/docker.nix
    ./virtualization/virtman.nix
    ./virtualization/looking-glass.nix
  ];

  nixpkgs.overlays =
    (lib.optionals qemu-patch.enable [(import ./overlays/qemu-custom.nix)]) ++
    (lib.optionals ovmf-patch.enable [(import ./overlays/ovmf-patch.nix)])
    ; # Add more by appending ++ to the last import

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
