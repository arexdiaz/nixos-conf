{ config, pkgs, lib, ... }:

{
  imports = [
    ./environment/kde.nix
    ./environment/gnome.nix
    ./core-pkgs.nix
    ./common-pkgs.nix
    ./emulators
    ./game-pkgs.nix
    ./kernel
    ./media-pkgs.nix
    ./tool-pkgs.nix
    ./shell/fish-shell.nix
    ./virtualization/docker.nix
    ./virtualization/virtman.nix
    ./shell/aliases/vfio
  ];

  options.preconfs = {
    pkgs = {
      core = {
        enable = lib.mkEnableOption "Whether to enable core packages.";
      };
      common = {
        enable = lib.mkEnableOption "Whether to enable common desktop packages.";
      };
      emulators = {
        enable = lib.mkEnableOption "Whether to enable emulator packages and configurations.";
      };
      games = {
        enable = lib.mkEnableOption "Whether to enable game packages.";
      };
      media = {
        enable = lib.mkEnableOption "Whether to enable media packages.";
      };
      tools = {
        enable = lib.mkEnableOption "Whether to enable tool packages.";
      };
    };
    system = {
      desktop.environment = {
        kde = {
          enable = lib.mkEnableOption "Whether to enable and configure the KDE Plasma desktop environment.";
        };
        gnome = {
          enable = lib.mkEnableOption "Whether to enable and configure the GNOME desktop environment.";
        };
        xserver = {
          enable = lib.mkEnableOption "Whether to enable the X server (required for graphical desktop environments).";
        };
      };
      kernel = {
        cachyos = {
          enable = lib.mkEnableOption "Whether to enable the CachyOS kernel and bpf scheduler.";
        };
        zen = {
          enable = lib.mkEnableOption "Placeholder bottomt text.";
          patch.rdtsc.enable = lib.mkEnableOption "Enable RDTSC patch for Zen kernel (can improve timing accuracy in VMs).";
        };
        patches = {
          rdtsc.enable = lib.mkEnableOption "Enable general RDTSC patch for the kernel (can improve timing accuracy in VMs).";
        };
        iommu = {
          enable = lib.mkEnableOption "Whether to enable IOMMU kernel parameters.";
          intel = lib.mkEnableOption "Add 'intel_iommu=on' to kernel parameters. Effective if IOMMU is enabled.";
          amd = lib.mkEnableOption "Add 'amd_iommu=on' to kernel parameters. Effective if IOMMU is enabled.";
          passthrough = lib.mkEnableOption "Add 'iommu=pt' to kernel parameters. Effective if IOMMU is enabled.";
          vfio.devices = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Comma-separated list of PCI device IDs (vendor:device) to bind to vfio-pci at boot. Example: \"10de:2489,10de:228b\".";
          };
        };
      };
      shell = {
        fish = {
          enable = lib.mkEnableOption "Whether to enable fish shell.";
        };
      };
      virtualization = {
        enable = lib.mkEnableOption "Whether to enable virtualization packages.";
        virtualManager = {
          enable = lib.mkEnableOption "Whether to install qemu with virtual manager.";
          QemuPatch = {
            enable = lib.mkEnableOption "Builds qemu with https://github.com/Scrut1ny/Hypervisor-Phantom patches.";
          };
          OvmfPatch = {
            enable = lib.mkEnableOption "Builds ovmf with https://github.com/Scrut1ny/Hypervisor-Phantom patches.";
          };
          libvirtdMembers = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "List of users to add to the libvirtd group.";
          };
          virtioWinISO = {
            enable = lib.mkEnableOption "Whether to install window drivers for virt manager.";
          };
        };
        docker = {
          enable = lib.mkEnableOption "Whether to enable Docker.";
          users = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "List of users to add to the docker group.";
          };
        };
      };
    };
  };

  config = {
    # Enable the X server if the corresponding option is set
    services.xserver.enable = config.preconfs.system.desktop.environment.xserver.enable;
  };
}
