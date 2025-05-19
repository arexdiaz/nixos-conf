{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    notion-app-electron.url = "github:arexdiaz/notion-app-electron";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      cRoot = ./.;
    in {
      nixosConfigurations = {
        lvnpc = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; inherit cRoot; flakeTarget = "lvnpc"; };
          modules = [ ./modules/hosts/thinkpad-p50 ];
        };

        scout = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; inherit cRoot; flakeTarget = "scout"; };
          modules = [ ./modules/hosts/scout ];
        };

        m1 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; inherit cRoot; flakeTarget = "m1"; };
          modules = [ ./hosts/apple-m1 ];
        };
      };
    };
}
