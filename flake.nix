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
          firaCode = pkgs.fira-code.override { useVariableFont = false; };
          fontPath = "${firaCode}/share/fonts/truetype:${pkgs.dejavu_fonts}/share/fonts/truetype";
          ntrecordRaw = pkgs.callPackage ./nix/ntrecord.nix { };
          ntrecord = pkgs.symlinkJoin {
            name = ntrecordRaw.name;
            paths = [ ntrecordRaw ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram "$out/bin/ntrecord" \
                --set XDG_DATA_HOME "${firaCode}/share" \
                --set-default NTRECORD_FONT_PATH "${fontPath}"
            '';
          };
          tailorPkgs = tailor.packages.${system} or { };
        in
        {
          default = pkgs.mkShell {
            NTRECORD_FONT_PATH = fontPath;
            shellHook = import ./nix/hooks.nix { inherit pkgs; };
            packages =
              with pkgs;
              [
                actionlint
                coreutils-full
                dejavu_fonts
                ffmpeg-headless
                firaCode
                gawk
                gh
                gnugrep
                gnused
                just
                ntrecord
              ]
              ++ (if tailorPkgs ? tailor then [ tailorPkgs.tailor ] else [ ])
              ++ import ./nix/loader.nix { inherit pkgs; };
          };
        }
      );
    };
}
