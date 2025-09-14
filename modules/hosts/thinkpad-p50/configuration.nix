{ config, ... }:
{
  networking = {
    hostName = "lvnpc";
    firewall.allowedTCPPorts = [ 3000 ];
  };

  # Enable beta nvidia drivers
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta; # Available options: stable | beta
  };

  boot.blacklistedKernelModules = [ "nouveau" ];
  programs.nix-ld.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
  services.thermald ={
    enable = true;
  };

  # local packages
  preconfs = {
    pkgs = {
      core.enable = true;
      common.enable = true;
      games.enable  = true;
      media.enable  = true;
      tools.enable  = true;
    };
    system = {
      desktop.environment.kde.enable = true;
      kernel = {
        cachyos.enable = false;
        scx.enable = false;
      };
      shell.fish.enable = true;
      virtualization = {
        enable = true;
        memprocfs.enable = true;
        virtualManager = {
          enable = true;
          libvirtdMembers = [ "rx" ];
          virtioWinISO.enable = true;
        };
        docker = {
          enable = true;
          users = [ "rx" ];
        };
      };
    };
  };

  system.stateVersion = "24.11";
}