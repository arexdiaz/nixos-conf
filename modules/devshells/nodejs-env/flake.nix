{
  description = "Next.js development environment with Prisma";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_20
            yarn
            git
            pgadmin
            prisma
            prisma-engines
            openssl
          ];

          shellHook = ''
            export PRISMA_SCHEMA_ENGINE_BINARY="${pkgs.prisma-engines}/bin/schema-engine"
            export PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines}/bin/query_engine"
            export PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines}/lib/libquery_engine.node"
            export PATH="./node_modules/.bin:$PATH"
          '';
        };
      }
    );
}