{ config, pkgs, inputs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    binwalk
    fzf
    git
    nix-init
    profile-sync-daemon
    tlrc
    vim
    wget
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