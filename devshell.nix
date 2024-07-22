{ lib,
  mkShell,
  pkgs,
  stdenv,
}:
mkShell {
  packages = with pkgs; ([
    ffmpeg-headless
    procps
    yq-go
  ]);

  shellHook = ''
  '';
}
