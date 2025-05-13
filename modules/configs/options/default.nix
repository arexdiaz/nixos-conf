{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./environment/kde.nix
    ./environment/gnome.nix
    ./bundle/core-pkgs.nix
    ./bundle/common-pkgs.nix
    ./bundle/emulators
    ./bundle/game-pkgs.nix
    ./bundle/media-pkgs.nix
    ./bundle/tool-pkgs.nix
    ./bundle/shell/fish-shell.nix
    ./bundle/virtualization/docker.nix
    ./bundle/virtualization/virtman.nix
  ];

  options.preconfs = {
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
    bundle = {
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
      shell = {
        fish = {
            enable = lib.mkEnableOption "Whether to enable fish shell.";
        };
      };
      virtualisation = {
        virtualManager = {
          enable = lib.mkEnableOption "Whether to install qemu with virtual manager.";
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
    services.xserver.enable = config.preconfs.desktop.environment.xserver.enable;
  };
}
