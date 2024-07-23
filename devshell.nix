{ lib,
  mkShell,
  pkgs,
  stdenv,
}:
mkShell {
  packages = with pkgs; ([
    coreutils-full
    ffmpeg-headless
    gawk
    gnugrep
    gnused
  ]);

  shellHook = ''
  '';
}
