{
  description = "AI Standards - Skills and Agents development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_24
            nodePackages.pnpm
            git
          ];

          # Helper function to fetch source code
          shellHook = ''
            # Create alias for opensrc (uses npx, no global install needed)
            alias opensrc="npx opensrc"

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "  AI Standards - Skills & Agents Dev Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Fetch source code for AI context:"
            echo "  npx opensrc <npm-package>         # e.g., npx opensrc zod"
            echo "  npx opensrc owner/repo            # e.g., npx opensrc powersync-ja/powersync-js"
            echo ""
            echo "Sources are stored in ./opensrc/"
            echo ""
          '';
        };
      }
    );
}
