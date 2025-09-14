{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.pkgs.core.enable {
  environment.systemPackages = with pkgs; [
    binwalk
    fzf
    git
    nix-init
    profile-sync-daemon
    tlrc
    vim
    wget
    unzip
    unrar-wrapper
    p7zip
  ];

  # Nixos options
  programs = {
    nh = {
      enable = true;
      clean.enable = true;
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # mtr.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };
}