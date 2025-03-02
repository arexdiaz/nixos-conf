{ config, pkgs, inputs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rx = {
    isNormalUser = true;
    description = "arexito";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Run commands as root w/o password.
  security.sudo.extraRules = [
    {
      users = [ "rx" ];
      commands = [
        {
          # Use the absolute path to psd-overlay-helper
          command = "${pkgs.profile-sync-daemon}/bin/psd-overlay-helper";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "rx" = import ./home-manager.nix;
    };
  };

  environment.systemPackages = with pkgs; [
    fishPlugins.done
    fishPlugins.fzf
    fishPlugins.forgit
    fishPlugins.hydro
    fishPlugins.grc
    grc
  ];

  programs = {
    fish = {
      enable = true;
      vendor = {
        functions.enable = true;
        config.enable = true;
        completions.enable = true;
      };

      shellAliases = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        l = "eza -l";
        nxr = "sudo nixos-rebuild switch --flake /etc/nixos#default";
        nxu = "sudo nix flake update --flake /etc/nixos/";
      };

      interactiveShellInit = "
        function nxc-toggle
            set owner (stat -c '%U' /etc/nixos)
            sudo chown -R (test $owner != $USER; and echo $USER:users; or echo root:root) /etc/nixos
            set state (test $owner != $USER; and echo 'unlocked'; or echo 'locked')
            echo \"nxc-toggle: $state /etc/nixos\"
        end
      ";
    };
  };
}