{ lib, config, pkgs, ... }:

let
  virtioWinISO = pkgs.stdenv.mkDerivation {
    name = "virtio-win.iso";
    src = pkgs.virtio-win; # Source directory of virtio drivers
    nativeBuildInputs = [ pkgs.cdrkit ]; # cdrkit provides genisoimage, a build tool
    installPhase = ''
      mkdir -p $out
      genisoimage -o $out/virtio-win.iso -J -R $src
    '';
  };
in
lib.mkMerge [
  # Main virt-manager configuration
  (lib.mkIf config.pkgs.bundle.virtualisation.virtualManager.enable {
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = config.pkgs.bundle.virtualisation.virtualManager.libvirtdMembers;

    environment.systemPackages = with pkgs; [
      virt-manager
    ] ++ lib.optionals config.pkgs.bundle.virtualisation.virtualManager.virtioWinISO.enable [
      virtioWinISO # Ensures the ISO is built and its path is part of the system closure
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
  })

  # Conditionally create a symlink for virtioWinISO in /var/lib/libvirt/images
  (lib.mkIf (config.pkgs.bundle.virtualisation.virtualManager.enable &&
             config.pkgs.bundle.virtualisation.virtualManager.virtioWinISO.enable) {
    systemd.tmpfiles.rules = [
      # L+ creates a symlink. If the path exists as a symlink, it's replaced.
      # It also creates parent directories of the symlink name (e.g., /var/lib/libvirt/images) if they don't exist.
      # The target of the symlink is the virtio-win.iso file within the Nix store derivation output.
      "L+ /var/lib/libvirt/images/virtio-win.iso - - - - ${virtioWinISO}/virtio-win.iso"
    ];
  })
]
