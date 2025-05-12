{ lib, config, pkgs, ... }:

lib.mkIf config.virtualisation.virtualManager.enable {
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = config.virtualisation.virtualManager.libvirtdMembers;

  environment.systemPackages = with pkgs; [
    virt-manager
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
