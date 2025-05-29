{ config, pkgs, ... }:

{
  networking.hostName = "scout";
  nixpkgs.config.allowUnfree = true;

  boot.blacklistedKernelModules = [ "nouveau" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      open    = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
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
          vfio_devs="10de:2489,10de:228b,1b21:0612,8086:43f0";
        };
      };
      shell.fish.enable = true;
      virtualization = {
        enable = true;
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
