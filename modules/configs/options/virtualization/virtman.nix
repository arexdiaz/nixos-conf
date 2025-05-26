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

  # Looking Glass SHM file parameters
  lookingGlassShmFile = "/dev/shm/looking-glass";
  lookingGlassShmUser = "rx";   # User 'rx' is configured with 'kvm' group access
  lookingGlassShmGroup = "kvm";  # 'kvm' group is typically used for virtualization resources. QEMU will size the file.
  lookingGlassShmSize = "32M"; # Default size. Consider making this configurable via NixOS options based on your VM's needs.
in
{
  config = lib.mkMerge [
    (lib.mkIf (virtualOptionConf.enable && virtualManagerCfg.enable) {
      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = virtualManagerCfg.libvirtdMembers;
      users.users.rx.extraGroups = [ "kvm" ];
      environment.systemPackages = with pkgs;
        lib.optionals isoCfg.enable [ virtioWinISO looking-glass-client ];

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
        "f ${lookingGlassShmFile} 0660 ${lookingGlassShmUser} ${lookingGlassShmGroup}  -   -"
      ];
    })
    (lib.mkIf (!isoCfg.enable) {
      systemd.tmpfiles.rules = [
        "R ${symlinkPath}"
      ];
    })
  ];
}
