{ config, pkgs, lib, ... }:

let
  virtioWinISO = pkgs.stdenv.mkDerivation {
    name = "virtio-win.iso";
    src = pkgs.virtio-win;
    buildInputs = [ pkgs.cdrkit ];
    installPhase = ''
      mkdir -p $out
      genisoimage -o $out/virtio-win.iso -J -R $src
    '';
    postInstall = ''
      mkdir -p /var/lib/libvirt/images
      ln -sf $out/virtio-win.iso /var/lib/libvirt/images/virtio-win.iso
    '';
  };
in
{
  options.vmTools = {
    virtualManager = {
      enable = lib.mkEnableOption "Whether to install qemu with virtual manager.";
      libvirtdMembers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of users to add to the libvirtd group.";
      };
      virtioWinISO = {
        enable = lib.mkEnableOption "Whether to install window drivers for virt manager.";
      };
    };
    docker = {
      enable = lib.mkEnableOption "Whether to enable Docker.";
      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of users to add to the docker group.";
      };
    };
  };

  imports = [
    ./virtman.nix
    ./docker.nix
  ];

  config = {
    environment.systemPackages = with pkgs;
      lib.optionals config.vmTools.virtualManager.virtioWinISO.enable [
        virtioWinISO
      ];
  };
}
