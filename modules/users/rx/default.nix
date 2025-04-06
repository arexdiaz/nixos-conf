{ config, pkgs, inputs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rx = {
    isNormalUser = true;
    description = "arexito";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
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
}