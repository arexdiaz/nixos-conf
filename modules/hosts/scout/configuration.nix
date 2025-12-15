{ config, pkgs, inputs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 6789 8000 ];
  networking.hostName = "scout";
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [ "uinput" ];
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
  preconfs = {
    pkgs = {
      core.enable = true;
      common.enable = true;
      games.enable = true;
      media = {
        enable = true;
        plex = {
          enable = true;
          user = "rx";
          timeoutStopSec = 5;
        };
      };
      tools.enable = true;
      emulators = {
        enable = true;
        wine.enable = true;
        gaming = {
          lutris.enable = true;
        };
      };
    };
    system = {
      desktop.environment = {
        kde.enable = true;
        xserver.enable = true;
      };
      kernel = {
        zen = {
          enable = true;
          patch.rdtsc.enable = false;
        };
        scx.enable = true;
        iommu = {
          enable = false;
          intel = true;
          passthrough = true;
          vfio.devices="10de:2489,10de:228b,1b21:0612";
        };
      };
      shell.zsh.enable = true;
      shell.zsh.ohMyZsh.enable = true;
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
          QemuPatch.enable = false;
          OvmfPatch.enable = false;
          libvirtdMembers = [ "rx" ];
          libvirtMembers = [ "rx" ];
          virtioWinISO.enable = true;
        };
        docker = {
          enable = true;
          users = [ "rx" ];
        };
      };
    };
  };

  programs.nix-ld.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
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

  system.stateVersion = "24.11"; # Current version is 25.05
}
