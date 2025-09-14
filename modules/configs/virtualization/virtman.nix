{ lib, config, pkgs, ... }:

let
  virtualOptionConf = config.preconfs.system.virtualization;
  virtualManagerCfg = virtualOptionConf.virtualManager;
  isoCfg = virtualManagerCfg.virtioWinISO;
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
  memprocfs = pkgs.callPackage ./leechcore.nix {};
in
{
  config = lib.mkMerge [
    (lib.mkIf (virtualOptionConf.enable && virtualManagerCfg.enable) {
      boot.kernel.sysctl."net.ipv4.ip_forward" = true;
      networking.firewall.trustedInterfaces = [ "virbr0" ];
      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = virtualManagerCfg.libvirtdMembers;
      users.groups.libvirt.members = virtualManagerCfg.libvirtdMembers;
      environment.systemPackages = with pkgs;
        (lib.optionals isoCfg.enable [ virtioWinISO ]) ++
        (lib.optionals virtualOptionConf.memprocfs.enable [ memprocfs ]);
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm; 
          runAsRoot = false;
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
      environment.variables = {
        LIBVIRT_DEFAULT_URI = "qemu:///system";
        LIBVIRT_DEFAULT_CONNECT_URI = "qemu:///system";
      };
      systemd.tmpfiles.rules = lib.mkIf (isoCfg.enable) [
        "L+ ${symlinkPath} - - - - ${isoStorePath}"
      ];
    })
    (lib.mkIf (!isoCfg.enable) {
      systemd.tmpfiles.rules = [
        "R ${symlinkPath}"
      ];
    })
  ];
}
