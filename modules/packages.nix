{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    eza
    fzf
    kdePackages.yakuake
    moonlight-qt
    nix-init
    profile-sync-daemon
    spotify
    tlrc
    vim
    wget
    vscode
    inputs.notion-app-electron.packages.${pkgs.system}.default
  ];

  # Nixos options
  programs = {
    firefox.enable = true;
    steam.enable = true;
    fish.enable = true;

    htop = {
      enable = true;
      package = htop;
      settings = {
        show_cpu_temperature = true;
        show_cpu_frequency = true;
      };
    };

    bash = {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
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