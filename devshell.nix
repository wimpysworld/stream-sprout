{ lib,
  mkShell,
  pkgs,
  stdenv,
}:
mkShell {
  packages = with pkgs; ([
    ffmpeg-headless
    gnugrep
    gnused
    mawk
    procps
  ]);

  shellHook = ''
  '';
}
