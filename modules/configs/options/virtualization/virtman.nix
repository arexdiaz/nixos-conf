{ lib, config, pkgs, ... }:

let
  virtualOptionConf = config.preconfs.pkgs.virtualisation;
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
in
{
  config = lib.mkMerge [
    (lib.mkIf (virtualOptionConf.enable && virtualManagerCfg.enable) {
      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = virtualManagerCfg.libvirtdMembers;

      environment.systemPackages = with pkgs;
        lib.optionals isoCfg.enable [ virtioWinISO ];

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
