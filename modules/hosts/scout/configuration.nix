{ config, pkgs, inputs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 6789 8000 28474 ];
  
  networking.hostName = "scout";
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

  # local packages
  preconfs = {
    pkgs = {
      core.enable = true;
      common.enable = true;
      games.enable = true;
      media.enable = true;
      tools.enable = true;
      emulators = {
        enable = true;
        wine.enable = true;
        gaming = {
          lutris.enable = true;
          pcsx2.enable = true;
        };
      };
    };
    system = {
      desktop.environment.kde.enable = true;
      kernel = {
        zen = {
          enable = true;
          patch.rdtsc.enable = true;
        };
        scx.enable = true;
        iommu = {
          enable = true;
          intel = true;
          passthrough = true;
          vfio.devices="10de:2489,10de:228b,1b21:0612";
        };
      };
      shell.fish.enable = true;
      virtualization = {
        enable = true;
        memprocfs.enable = true;
        looking-glass = {
          enable = true;
          vmNames = [ "win10-vmlike" ];
          shmSize = 32;
          fullscreen = true;
        };
        virtualManager = {
          enable = true;
          QemuPatch.enable = true;
          OvmfPatch.enable = true;
          libvirtdMembers = [ "rx" ];
          virtioWinISO.enable = true;
        };
      };
    };
  };

  services = {
    plex = {
      enable = true;
      openFirewall  = true;
      user = "rx";
    };
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
  fuse
  libusb1
];
  powerManagement.cpuFreqGovernor = "performance";

  fileSystems = {
    "/mnt/Stuff" = {
      device  = "/dev/disk/by-uuid/d4a092ab-ae4a-43b5-821b-3aa104a572a1";
      fsType  = "ext4";
      options = [ "users" "nofail" "exec" ];
    };

    "/mnt/Stuff2" = {
      device  = "/dev/disk/by-uuid/7bb68649-8e30-4cfc-846c-4da6f520fe1a";
      fsType  = "ext4";
      options = [ "users" "nofail" "exec" ];
    };
  };
  
  # services.thermald ={
  #   enable = true;
  # };

  system.stateVersion = "24.11";
}
