{ pkgs, lib }:

let
  misc = pkgs.fetchFromGitHub {
    owner = "arexdiaz";
    repo = "patches";
    rev = "8a4ff580356709385dad4e5570ad6d4f4becc0e8";
    sha256 = "sha256-ImdotMTQKcqOn9NWgoB0LmHqQio10Z9zcFJcI5+6QEk=";
  };

  zenKernelsFor = { version, suffix, sha256, isLqx ? false }: pkgs.buildLinux ({
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

    kernelPatches = [{
      name = "vmx-cpuid-patch";
      patch = "${misc}/cpuid-leaf.patch";
    }
    {
      name = "rc6-patch";
      patch = "${misc}/rc6v2.patch";
    }
    {
      name = "vmx-tracer-patch";
      patch = ../patches/vmx.patch;
    }];

    structuredExtraConfig = with lib.kernel; {
      ZEN_INTERACTIVE = yes;
      NET_SCH_DEFAULT = yes;
      DEFAULT_FQ_CODEL = yes;
      PREEMPT = lib.mkForce yes;
      PREEMPT_VOLUNTARY = lib.mkForce no;
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
      IOSCHED_BFQ = lib.mkForce yes;
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

  zen = {
    version = "6.15.8";
    suffix = "zen1";
    sha256 = "sha256-pO1xTnFohy6UWv3W0YPqA8KQLDfssQR5ZktalRgoEwQ=";
  };

in
  pkgs.linuxPackagesFor (zenKernelsFor zen)