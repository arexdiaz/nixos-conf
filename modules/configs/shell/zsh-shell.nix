{ config, pkgs, lib, ... }:

let
  cfg = config.preconfs.system.shell.zsh;
  p10kConfig = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/config/p10k-lean.zsh";
in

lib.mkIf cfg.enable {
  environment.systemPackages = with pkgs; [
    grc
    eza
  ];
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;

  fonts = lib.mkIf cfg.ohMyZsh.enable {
    packages = [ pkgs.meslo-lgs-nf ];
  };

  environment.etc = lib.mkIf cfg.ohMyZsh.enable {
    "zsh/p10k.zsh".source = p10kConfig;
  };

  programs = {
    zsh =
      {
        enable = true;
        enableCompletion = true;

        shellAliases = lib.mkMerge [{
          ls = "eza";
          ll = "eza -l";
          la = "eza -la";
          l = "eza -l";
          nrs = "nh os switch";
          nrt = "nh os test";
          nca = "nh clean all -a";
        }];

        shellInit = ''
          export NH_OS_FLAKE="/etc/nixos"
        '';
      }
      // lib.optionalAttrs cfg.ohMyZsh.enable {
        ohMyZsh = {
          enable = true;
          theme = "powerlevel10k/powerlevel10k";
          customPkgs = [ pkgs.zsh-powerlevel10k ];
          plugins = [
            "fzf"
            "git"
            "command-not-found"
            "zsh-interactive-cd"
          ];
        };

        interactiveShellInit = ''
          if [ -r ~/.p10k.zsh ]; then
            source ~/.p10k.zsh
          elif [ -r /etc/zsh/p10k.zsh ]; then
            source /etc/zsh/p10k.zsh
          fi
        '';
      };
  };
}
