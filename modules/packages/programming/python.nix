{ config, pkgs , ... }:

{
  environment.systemPackages = with pkgs; [
    python313
    python313Packages.beautifulsoup4
    python313Packages.jupyter-core
    python313Packages.pandas
    python313Packages.pip
    python313Packages.requests
  ];
}