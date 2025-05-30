{ config, pkgs, lib, ... }:

lib.mkIf config.preconfs.system.shell.fish.enable {
  environment.systemPackages = with pkgs; [
    fishPlugins.done
    fishPlugins.fzf
    fishPlugins.forgit
    fishPlugins.hydro
    fishPlugins.grc
    grc
    eza
  ];

  programs = {
    fish = {
      enable = true;
      vendor = {
        functions.enable = true;
        config.enable = true;
        completions.enable = true;
      };

      shellAliases = lib.mkMerge [{
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        l = "eza -l";
        nrs = "nh os switch";
        nrt = "nh os test";
        nca = "nh clean all -a";
      }];

      interactiveShellInit = "
        function nxc-toggle
            set owner (stat -c '%U' /etc/nixos)
            sudo chown -R (test $owner != $USER; and echo $USER:users; or echo root:root) /etc/nixos
            set state (test $owner != $USER; and echo 'unlocked'; or echo 'locked')
            echo \"nxc-toggle: $state /etc/nixos\"
        end

        function fish-dev
          if test (count $argv) -ne 1
              echo 'Usage: fish-dev <path>'
              return 1
          end
          nix develop $argv[1] --command fish
        end

        for dir in (ls -d /etc/nixos/modules/devshells/*/)
            set alias_name (basename $dir)
            alias $alias_name=\"fish-dev $dir\"
        end

        # ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

        set -gx NH_OS_FLAKE \"/etc/nixos\";
      ";
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