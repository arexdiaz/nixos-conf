{ config, ... }:
{
  networking = {
    hostName = "lvnpc";
    firewall.allowedTCPPorts = [ 3000 43595 ];
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
        cachyos.enable = true;
        scx.enable = true;
      };
      shell.fish.enable = true;
      virtualization = {
        enable = false;
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