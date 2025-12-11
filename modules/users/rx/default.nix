{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
  ];
  nix.settings.trusted-users = [ "rx" ];
  users.users.rx = {
    isNormalUser = true;
    description = "arexito";
    extraGroups = [ "networkmanager" "wheel" "i2c" "input" "kvm" ];
    shell = pkgs.zsh;
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
    backupFileExtension = ".bak";
    extraSpecialArgs = { inherit inputs; };
    users = {
      "rx" = import ./home-manager.nix;
    };
  };
}
