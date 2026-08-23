{
  description = "Toolchain for n8.gay, a Hugo site";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          # Hugo in nixpkgs is the extended build, which the vendored
          # hello-friend theme needs for its SCSS pipeline.
          packages = with pkgs; [ hugo ];

          shellHook = ''
            echo "$(hugo version | cut -d'+' -f1) — n8.gay"
            echo "  hugo server   live preview at http://localhost:1313"
            echo "  hugo          build into public/"
            echo ""
            echo "Cloudflare Pages serves the committed public/ directory and does"
            echo "NOT run Hugo, so public/ must be rebuilt and committed to deploy."
          '';
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
    };
}
