{ config, pkgs, inputs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    eza
    fzf
    nix-init
    profile-sync-daemon
    python3
    tlrc
    vim
    wget
  ];

  # Nixos options
  programs = {
    programs.nh = {
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