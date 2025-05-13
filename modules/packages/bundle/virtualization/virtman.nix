{ lib, config, pkgs, ... }:

let
  vmCfg = config.pkgs.bundle.virtualisation.virtualManager;
  isoCfg = vmCfg.virtioWinISO;
  symlinkPath = "/var/lib/libvirt/images/virtio-win.iso";

  virtioWinISO = pkgs.stdenv.mkDerivation {
    name = "virtio-win.iso";
    src = pkgs.virtio-win;
    nativeBuildInputs = [ pkgs.cdrkit ];
    installPhase = ''
      mkdir -p $out
      genisoimage -o $out/virtio-win.iso -J -R $src
    '';
  };

  isoStorePath = "${virtioWinISO}/virtio-win.iso";
in
lib.mkMerge [
  # Main virt-manager configuration
  (lib.mkIf vmCfg.enable {
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = vmCfg.libvirtdMembers;

    environment.systemPackages = with pkgs; [
      virt-manager
    ] ++ lib.optionals isoCfg.enable [
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
  })

  (lib.mkIf (vmCfg.enable && isoCfg.enable) {
    systemd.tmpfiles.rules = [
      "L+ ${symlinkPath} - - - - ${isoStorePath}"
    ];
  })

  (lib.mkIf (vmCfg.enable && !isoCfg.enable) {
    system.activationScripts.removeVirtioWinIsoSymlink = {
      text = ''
        # Check if the symlink exists.
        # We only want to remove it if it was likely created by this module.
        if [ -L "${symlinkPath}" ]; then
          # If the option is off, and the symlink exists, remove it.
          # This assumes no other process is managing a symlink at this exact path.
          echo "virtioWinISO.enable is false; removing symlink ${symlinkPath}."
          rm -f "${symlinkPath}"
        fi
      '';
    };
  })
]
