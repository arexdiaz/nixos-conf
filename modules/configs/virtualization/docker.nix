{ lib, config, pkgs, ... }:

lib.mkIf config.preconfs.system.virtualization.docker.enable {

  programs.fish.shellAliases = {
    dcu = "docker compose up";
    dcd = "docker compose down";
    dcr = "docker compose restart";
    dcp = "docker compose ps";
    dcl = "docker compose logs";
    dce = "docker compose exec";
    dcb = "docker compose build";
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      experimental = true;
      default-address-pools = [
        {
          base = "172.30.0.0/16";
          size = 24;
        }
      ];
    };
  };

  # Enable Docker buildx for cross-platform builds
  environment.systemPackages = with pkgs; [
    docker-buildx
  ];

  users.extraGroups.docker.members = config.preconfs.system.virtualization.docker.users;
  users.users = builtins.listToAttrs (map (userName: {
    name = userName;
    value.extraGroups = [ "docker" ];
  }) config.preconfs.system.virtualization.docker.users);
}