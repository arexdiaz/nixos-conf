{ config, pkgs, ... }:

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
in {
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["rx"];

  environment.systemPackages = with pkgs; [
    virt-manager
    virtioWinISO
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };
}
