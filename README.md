<h1 align="center">
  <img src="pages/icon.png" width="256" height="256" alt="Stream Sprout">
  <br />
  Stream Sprout
</h1>

<p align="center"><b>Restream one video source to Twitch, YouTube, Owncast, PeerTube, and other platforms at the same time.</b></p>

<p align="center">
  <a href="https://stream-sprout.wimpys.world/">Website</a> |
  <a href="https://github.com/wimpysworld/stream-sprout/wiki">Documentation</a>
</p>

Stream Sprout receives a single RTMP stream from [OBS Studio](https://obsproject.com/) (or any RTMP encoder) through [FFmpeg](https://ffmpeg.org/) and forwards it to multiple destinations without transcoding. It runs beside OBS Studio on Linux or macOS without root privileges, third-party relay fees, or a separate web server.

<div align="center">
  <img src="pages/demo.webp" alt="Stream Sprout terminal output during a multi-destination broadcast" width="846" height="578">
</div>

## Features

- Restream one broadcast to Twitch, YouTube, [Owncast](https://owncast.online/), [PeerTube](https://joinpeertube.org/), and any `rtmp://` or `rtmps://` destination.
- Copy video and audio tracks without transcoding, so extra destinations add no extra encoding load.
- Keep active destinations live when one destination fails through FFmpeg's `onfail=ignore` tee option.
- Save an optional local Matroska (`.mkv`) archive of each broadcast with a timestamped filename.
- Manage all server and destination settings in one `stream-sprout.yaml` file that reloads between broadcasts.

## Install

| | Platform | Repository |
| :-: | --- | --- |
| <img src="https://apt.wimpys.world/logo.svg" width="32" height="32" alt=""> | Debian and Ubuntu | [apt.wimpys.world](https://apt.wimpys.world/#stream-sprout) |
| <img src="https://rpm.wimpys.world/logo.svg" width="32" height="32" alt=""> | Fedora and openSUSE | [rpm.wimpys.world](https://rpm.wimpys.world/#stream-sprout) |
| <img src="https://pkg.wimpys.world/logo.svg" width="32" height="32" alt=""> | Arch Linux | [pkg.wimpys.world](https://pkg.wimpys.world/#stream-sprout) |
| <img src="https://apk.wimpys.world/logo.svg" width="32" height="32" alt=""> | Alpine Linux | [apk.wimpys.world](https://apk.wimpys.world/#stream-sprout) |
| <img src="https://nix.wimpys.world/logo.svg" width="32" height="32" alt=""> | Nix and NixOS | [nix.wimpys.world](https://nix.wimpys.world/#stream-sprout) |

Each repository is signed, and its page gives the setup steps and keeps Stream Sprout up to date.

### Container

Images are published to the GitHub Container Registry for `linux/amd64` and `linux/arm64`.

Pull the latest image:

```shell
docker pull ghcr.io/wimpysworld/stream-sprout:latest-alpine
```

Mount the directory that holds `stream-sprout.yaml` and expose the RTMP port:

```shell
docker run -p 1935:1935 -it -v "$PWD:/data" \
  ghcr.io/wimpysworld/stream-sprout:latest-alpine \
  --config /data/stream-sprout.yaml
```

- `-p 1935:1935` exposes the RTMP server port `1935` on the host. Change it when `stream-sprout.yaml` sets a different port.
- `-it` runs the container interactively.
- `-v "$PWD:/data"` mounts the current directory as `/data` inside the container.

Build the container image locally:

```shell
docker build -f Containerfile -t stream-sprout .
```

### From source

Stream Sprout requires Bash 5.0 or later and [FFmpeg](https://ffmpeg.org/) on `PATH`.

```shell
git clone https://github.com/wimpysworld/stream-sprout.git
cd stream-sprout
```

## Usage

Create `stream-sprout.yaml` in your working directory (or copy [`stream-sprout.yaml.example`](stream-sprout.yaml.example)):

```yaml
server:
  ip: 127.0.0.1
  port: 1935
  app: sprout
  key: replace_with_uuidgen_key
  archive_stream: false
  archive_path: ~/Streams

services:
  twitch:
    enabled: true
    rtmp_server: rtmp://live.twitch.tv/app/
    key: your_twitch_stream_key
  youtube:
    enabled: true
    rtmp_server: rtmp://a.rtmp.youtube.com/live2/
    key: your_youtube_stream_key
```

Start Stream Sprout:

```shell
stream-sprout
```

In OBS Studio, open `Settings` > `Stream`, choose `Custom`, enter `rtmp://127.0.0.1:1935/sprout` as the `Server`, paste your `server.key` value into `Stream Key`, and click **Start Streaming**. Press <kbd>Ctrl</kbd>+<kbd>C</kbd> in the terminal to stop `stream-sprout`.

| Option | Description |
| --- | --- |
| `--config <path>` | Load a configuration file from a custom path. |
| `--info` | Print operating system, container runtime, `awk`, `bash`, and `ffmpeg` versions for bug reports. |
| `--version` | Print the Stream Sprout and FFmpeg versions. |
| `--help` | Display usage help and exit. |

> [!WARNING]
> FFmpeg does not enforce the `app` or `key` path on its incoming RTMP listener and accepts any stream on the configured port. Do not expose the RTMP port to untrusted networks without a VPN, SSH tunnel, or firewall. Read [Security and limitations](https://github.com/wimpysworld/stream-sprout/wiki/Security-and-Limitations) before listening on a non-loopback address.

## Documentation

- [Configuration](https://github.com/wimpysworld/stream-sprout/wiki/Configuration) - Config search paths, `server:` options, local stream archiving, and Twitch, YouTube, Owncast, PeerTube, and RTMPS targets.
- [OBS Studio](https://github.com/wimpysworld/stream-sprout/wiki/OBS-Studio) - OBS Studio setup walkthrough and remote-host connection notes.
- [Security and limitations](https://github.com/wimpysworld/stream-sprout/wiki/Security-and-Limitations) - FFmpeg RTMP key enforcement caveat, VPN, SSH tunnel, and firewall hardening, and upload bandwidth limits.
- [References](https://github.com/wimpysworld/stream-sprout/wiki/References) - Upstream FFmpeg, OBS Studio, and container references plus `stream-sprout --info` bug-report guidance.
