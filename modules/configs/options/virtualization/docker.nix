 { lib, config, pkgs, ... }:

# This module's content is conditional on the docker enable option
lib.mkIf config.preconfs.system.virtualization.docker.enable {
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # Enable the system-level Docker service
  virtualisation.docker.enable = true;

  # Add specified users to the 'docker' group
  # This uses the `users` option defined in virtualization/default.nix
  users.extraGroups.docker.members = config.preconfs.system.virtualization.docker.users;
  users.users = builtins.listToAttrs (map (userName: {
    name = userName;
    value.extraGroups = [ "docker" ];
  }) config.preconfs.system.virtualization.docker.users);
}