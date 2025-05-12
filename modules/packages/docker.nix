{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
  virtualisation.docker.enable = true;
  users = {
    users.rx.extraGroups = [ "docker" ];
    extraGroups.docker.members = [ "rx" ];
  };
}