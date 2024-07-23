{ lib
, installShellFiles
, makeWrapper
, stdenv
, coreutils-full
, ffmpeg-headless
, gawk
, gnugrep
, gnused
, procps
}:
let
  runtimePaths = [
    coreutils-full
    ffmpeg-headless
    gawk
    gnugrep
    gnused
  ];
  versionMatches =
    builtins.match ''
      .*
      readonly[[:blank:]]VERSION="([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)"
      .*
    '' (builtins.readFile ./stream-sprout);
in
stdenv.mkDerivation rec {
  pname = "stream-sprout";
  version = builtins.concatStringsSep "" versionMatches;
  src = lib.cleanSource ./.;

  nativeBuildInputs = [ makeWrapper installShellFiles ];

  installPhase = ''
    runHook preInstall
    install -Dm755 -t "$out/bin" stream-sprout
    runHook postInstall
  '';

  meta = {
    description = "Re-stream a video source to multiple destinations such as Twitch, YouTube, and Owncast.";
    homepage = "https://github.com/wimpysworld/stream-sprout";
    mainProgram = "stream-sprout";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ flexiondotorg ];
  };
}
