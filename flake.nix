{
  description = "Stream Sprout flake";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
    tailor.url = "github:wimpysworld/tailor/latest";
  };

  outputs =
    {
      flake-schemas,
      nixpkgs,
      tailor,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      schemas = flake-schemas.schemas;

      overlays = forAllSystems (
        _:
        {
          default = final: _prev: {
            stream-sprout = final.callPackage ./nix/package.nix { };
          };
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          stream-sprout = pkgs.callPackage ./nix/package.nix { };
        in
        {
          inherit stream-sprout;
          default = stream-sprout;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          tailorPkgs = tailor.packages.${system} or { };
        in
        {
          default = pkgs.mkShell {
            shellHook = import ./nix/hooks.nix { inherit pkgs; };
            packages =
              with pkgs;
              [
                actionlint
                coreutils-full
                ffmpeg-headless
                gawk
                gh
                gnugrep
                gnused
                just
              ]
              ++ (if tailorPkgs ? tailor then [ tailorPkgs.tailor ] else [ ])
              ++ import ./nix/loader.nix { inherit pkgs; };
          };
        }
      );
    };
}
