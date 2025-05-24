{ config, pkgs, lib, ... }:

let
  mkKernelOverride = lib.mkOverride 90;
  zen = {
    version = "6.14.6";
    suffix = "zen1";
    sha256 = "0qrx0c8bza9jj84ax209h3b9w2yn2sh122qj9ki77c8wgp6rwvrm";
    isLqx = false;
  };
  rdtsc-patch = pkgs.fetchFromGitHub {
    owner = "YungBinary";
    repo = "RDTSC-KVM-Handler-v2";
    rev = "1d01edc6fab44ca2eb8db2eea95abcb29e818ef8";
    sha256 = "sha256-7UWG+QgYaa/m0qyehSh+QO0WE6ZlW2hqqvaBJ3Pxqpo=";
  };
  zenKernelsFor = { version, suffix, sha256, isLqx }: pkgs.buildLinux ({
    inherit version;
    pname = "linux-${if isLqx then "lqx" else "zen"}";
    modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
    isZen = true;

    src = pkgs.fetchFromGitHub {
      owner = "zen-kernel";
      repo = "zen-kernel";
      rev = "v${version}-${suffix}";
      inherit sha256;
    };

    structuredExtraConfig = with lib.kernel; {
      ZEN_INTERACTIVE = yes;
      NET_SCH_DEFAULT = yes;
      DEFAULT_FQ_CODEL = yes;
      PREEMPT = mkKernelOverride yes;
      PREEMPT_VOLUNTARY = mkKernelOverride no;
      TREE_RCU = yes;
      PREEMPT_RCU = yes;
      RCU_EXPERT = yes;
      TREE_SRCU = yes;
      TASKS_RCU_GENERIC = yes;
      TASKS_RCU = yes;
      TASKS_RUDE_RCU = yes;
      TASKS_TRACE_RCU = yes;
      RCU_STALL_COMMON = yes;
      RCU_NEED_SEGCBLIST = yes;
      RCU_FANOUT = freeform "64";
      RCU_FANOUT_LEAF = freeform "16";
      RCU_BOOST = yes;
      RCU_BOOST_DELAY = option (freeform "500");
      RCU_NOCB_CPU = yes;
      RCU_LAZY = yes;
      RCU_DOUBLE_CHECK_CB_TIME = yes;
      IOSCHED_BFQ = mkKernelOverride yes;
      FUTEX = yes;
      FUTEX_PI = yes;
      NTSYNC = yes;
      HZ = freeform "1000";
      HZ_1000 = yes;
    };

    passthru.updateScript = [
      ./update-zen.py
      (if isLqx then "lqx" else "zen")
    ];
  });
in
{
  config = lib.mkIf config.preconfs.pkgs.kernel.zen-patched.enable {
    boot = {
      kernelPackages = pkgs.linuxPackagesFor (zenKernelsFor zen);
      kernelPatches = [{
        name = "vmx-rdtsc-patch";
        patch = "${rdtsc-patch}/kernel-patch-6.8.0-49.patch";
      }];
    };
  };
}