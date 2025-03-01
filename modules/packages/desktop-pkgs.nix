{ config, pkgs, inputs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    kdePackages.kdeconnect-kde
    kdePackages.krdc
    kdePackages.yakuake
    onlyoffice-desktopeditors
    vscode
    inputs.notion-app-electron.packages.${pkgs.system}.default
  ];

  programs = {
    firefox.enable = true;
    fish.enable = true;

    htop = {
      enable = true;
      package = pkgs.htop;
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
  };
}