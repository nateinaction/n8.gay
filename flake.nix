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
          packages = with pkgs; [
            hugo

            # QR code for the site, plus the tools to prove it decodes to what
            # we think it does. See README: a QR nobody can scan is worse than
            # no QR, and you cannot tell by looking at it.
            qrencode
            librsvg # rsvg-convert, to rasterize the SVG for decoding
            zbar # zbarimg, to read the code back
          ];

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
