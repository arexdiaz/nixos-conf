{ config, lib, pkgs, ... }:

let
  cfg = config.preconfs.system.virtualization.looking-glass;
in
lib.mkIf cfg.enable {
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      config.boot.kernelPackages.kvmfr
    ];
    kernelModules = [ "kvmfr" ];
    kernelParams = [ "kvmfr.static_size_mb=${toString cfg.shmSize}" ];
  };
  environment.systemPackages = with pkgs; [ looking-glass-client ];

  services.udev.extraRules = ''KERNEL=="kvmfr*", OWNER="${cfg.user}", GROUP="${cfg.group}", MODE="${cfg.permissions}"'';

  virtualisation.libvirtd = {
    qemu.verbatimConfig = ''
      namespaces = []
      cgroup_device_acl = [
        "/dev/null", "/dev/full", "/dev/zero", "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm", "/dev/kvmfr0"
      ]
    '';
    hooks.qemu = {};
  };
}