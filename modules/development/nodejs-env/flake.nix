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
            # Core JS Tooling
            nodejs_20 # Specify a Node.js version if needed, e.g., nodejs_20
            yarn
            git
            pgadmin

            # Add Prisma CLI and Engines
            prisma
            prisma-engines
            openssl
          ];

          shellHook = ''
            echo "Node.js and Prisma dev env loaded"

            # Optional: Set PRISMA_SCHEMA_ENGINE_BINARY if still needed,
            # but usually the prisma-engines package handles this.
            export PRISMA_SCHEMA_ENGINE_BINARY="${pkgs.prisma-engines}/bin/schema-engine"
            export PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines}/bin/query_engine"
            export PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines}/lib/libquery_engine.node"
            # LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7}')
            # export NEXTAUTH_URL="http://$LOCAL_IP:3000"
            # Add node_modules/.bin to PATH for locally installed CLIs like next
            export PATH="./node_modules/.bin:$PATH"
          '';
        };
      }
    );
}