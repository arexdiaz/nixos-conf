{ config, pkgs, ... }:

{
  networking.hostName = "scout";
  nixpkgs.config.allowUnfree = true;

  boot.blacklistedKernelModules = [ "nouveau" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      open    = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
    };
    graphics = {
      enable        = true;
      extraPackages = with pkgs; [nvidia-vaapi-driver];
    };
  };

  boot.kernelParams = [
    "vfio-pci.ids=10de:2489,10de:228b,1b21:0612"
    "video=efifb:off"
  ];

  # local packages
  preconfs = {
    desktop.environment.kde.enable = true;
    pkgs = {
      kernel = {
        zen-patched.enable = true;
        scx.enable = true;
        iommu = {
          enable = true;
          intel = true;
          passthrough = true;
        };
      };
      core.enable = true;
      common.enable = true;
      games.enable = true;
      media.enable = true;
      tools.enable = true;
      shell.fish.enable = true;
      virtualisation = {
        enable = true;
        virtualManager = {
          enable = true;
          QemuPatch.enable = false;
          OvmfPatch.enable = false;
          libvirtdMembers = [ "rx" ];
          virtioWinISO.enable = true;
        };
      };
      emulators = {
        enable = true;
        wine.enable = true;
        gaming = {
          lutris.enable = true;
          pcsx2.enable = true;
        };
      };
    };
  };

  services = {
    plex = {
      enable = false;
      openFirewall  = true;
      user = "rx";
    };
    # RDP Setup
    xrdp = {
      enable = false;
      openFirewall = true;
      defaultWindowManager = "startplasma-wayland";
    };
  };

  programs.nix-ld.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  fileSystems = {
    "/mnt/Stuff" = {
      device  = "/dev/disk/by-uuid/d4a092ab-ae4a-43b5-821b-3aa104a572a1";
      fsType  = "ext4";
      options = [ "users" "nofail" "exec" ];
    };
    "/mnt/Stuff2" = {
      device  = "/dev/disk/by-uuid/CA33-738B";
      fsType  = "vfat";
      options = [ "users" "nofail" "exec" ];
    };
  };
  
  # services.thermald ={
  #   enable = true;
  # };

  system.stateVersion = "24.11";
}
